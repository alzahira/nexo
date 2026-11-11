import 'package:app_home/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthProvider sin Firebase configurado', () {
    test('loginConEmail no finge un inicio de sesión correcto', () async {
      final auth = AuthProvider();

      expect(auth.firebaseAvailable, isFalse);

      final ok = await auth.loginConEmail('test@example.com', '123456');

      expect(ok, isFalse);
      expect(auth.errorMessage, contains('Firebase'));
      expect(auth.isLoggedIn, isFalse);
      expect(auth.isLoading, isFalse);
    });

    test('registrarConEmail tampoco devuelve éxito', () async {
      final auth = AuthProvider();

      final ok = await auth.registrarConEmail('test@example.com', '123456');

      expect(ok, isFalse);
      expect(auth.errorMessage, AuthProvider.mensajeSinFirebase);
      expect(auth.isLoggedIn, isFalse);
    });

    test('loginConGoogle avisa en lugar de fallar en silencio', () async {
      final auth = AuthProvider();

      final ok = await auth.loginConGoogle();

      expect(ok, isFalse);
      expect(auth.errorMessage, AuthProvider.mensajeSinFirebase);
    });
  });

  group('Modo invitado', () {
    test('activa la sesión y expone el id de invitado', () {
      final auth = AuthProvider();

      auth.entrarComoInvitado();

      expect(auth.isLoggedIn, isTrue);
      expect(auth.userId, 'usuario_invitado');
      expect(auth.user, isNull);
    });

    test('cerrarSesion limpia también la sesión de invitado', () async {
      final auth = AuthProvider();
      auth.entrarComoInvitado();

      await auth.cerrarSesion();

      expect(auth.isLoggedIn, isFalse);
      expect(auth.userId, isNull);
      expect(auth.errorMessage, isNull);
    });
  });
}
