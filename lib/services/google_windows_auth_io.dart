import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:url_launcher/url_launcher.dart';

/// Acceso con Google en Windows/Linux/macOS.
///
/// Abre una página alojada en Firebase Hosting que hace el popup de Google con
/// el SDK web. Esa página devuelve el `idToken` a un servidor HTTP local
/// (127.0.0.1) que solo escucha durante el inicio de sesión.
class GoogleWindowsAuth {
  static const String _hostedPage =
      'https://app-home-familia.web.app/google-signin.html';

  static Future<Map<String, String>> signIn({String? email}) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final state = _randomState();
    final completer = Completer<Map<String, String>>();

    final subscription = server.listen((request) async {
      final params = request.uri.queryParameters;
      final isCallback = request.uri.path == '/' && params['state'] == state;

      if (!isCallback) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }

      final error = params['error'];
      final idToken = params['idToken'];
      final fallo = (error != null && error.isNotEmpty)
          ? error
          : (idToken == null || idToken.isEmpty)
              ? 'Google no devolvió un token de acceso válido.'
              : null;

      request.response
        ..headers.contentType = ContentType.html
        ..write(_resultPage(fallo));
      await request.response.close();

      if (completer.isCompleted) return;

      if (fallo != null) {
        completer.completeError(StateError(fallo));
        return;
      }

      completer.complete({
        'idToken': idToken!,
        'accessToken': params['accessToken'] ?? '',
      });
    });

    final emailParam = (email == null || email.isEmpty)
        ? ''
        : '&loginHint=${Uri.encodeQueryComponent(email)}';
    final url = Uri.parse(
      '$_hostedPage?port=${server.port}&state=$state$emailParam',
    );

    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched) {
      await subscription.cancel();
      await server.close(force: true);
      throw StateError('No se pudo abrir el navegador para acceder con Google.');
    }

    try {
      return await completer.future.timeout(const Duration(minutes: 5));
    } on TimeoutException {
      throw StateError(
        'Se agotó el tiempo para completar el acceso con Google. '
        'Vuelve a intentarlo.',
      );
    } finally {
      await subscription.cancel();
      await server.close(force: true);
    }
  }

  static String _randomState() {
    final random = Random.secure();
    final bytes = List<int>.generate(24, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static String _resultPage(String? fallo) => '''
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Nexo</title>
  <style>
    body { font-family: system-ui, -apple-system, Segoe UI, sans-serif;
           background: #f8f4ee; color: #2e3a34; display: flex;
           align-items: center; justify-content: center; height: 100vh;
           margin: 0; padding: 24px; box-sizing: border-box; }
    main { background: #fff; padding: 32px 40px; border-radius: 24px;
           border: 1px solid #e8e0d3; text-align: center; max-width: 460px;
           box-shadow: 0 8px 24px rgba(46,58,52,.08); }
    h1 { font-size: 20px; margin: 0 0 8px; }
    p { margin: 0; color: #66736b; line-height: 1.5; }
  </style>
</head>
<body>
  <main>
    <h1>${fallo == null ? 'Acceso completado' : 'No se pudo completar el acceso'}</h1>
    <p>${fallo ?? 'Ya puedes cerrar esta pestaña y volver a Nexo.'
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')}</p>
  </main>
</body>
</html>
''';
}
