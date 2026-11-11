import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:http/http.dart' as http;
import '../models/common/app_event.dart';

/// Error de permisos: no hay sesión de Google o el token ha caducado.
class CalendarAuthException implements Exception {
  final String mensaje;
  const CalendarAuthException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Resultado de una sincronización completa (subida + bajada).
class ResultadoSincronizacion {
  final List<AppEvent> eventosGoogle;
  final int enviados;
  final int importados;
  final int eliminados;

  const ResultadoSincronizacion({
    required this.eventosGoogle,
    required this.enviados,
    required this.importados,
    this.eliminados = 0,
  });
}

class GoogleCalendarService {
  /// Devuelve el token de acceso de Google Calendar, o `null` si no hay
  /// sesión de Google válida.
  final Future<String?> Function() _tokenProvider;

  GoogleCalendarService(this._tokenProvider);

  /// Sincroniza en los dos sentidos:
  /// - sube a Google Calendar los eventos locales que aún no existen;
  /// - descarga los eventos de Google Calendar para mostrarlos en la app.
  Future<ResultadoSincronizacion> sincronizar(List<AppEvent> eventosLocales) async {
    debugPrint("GOOGLE_CALENDAR: Iniciando sincronización...");

    final String? token = await _tokenProvider();
    if (token == null || token.isEmpty) {
      throw const CalendarAuthException(
        'Conecta tu cuenta de Google para sincronizar el calendario.',
      );
    }

    final authenticatedClient = GoogleAuthClient(token);
    final calendar = cal.CalendarApi(authenticatedClient);

    try {
      final hoy = DateTime.now();
      final minTime = DateTime(hoy.year, hoy.month, hoy.day)
          .subtract(const Duration(days: 365))
          .toUtc();
      final maxTime = DateTime(hoy.year, hoy.month, hoy.day)
          .add(const Duration(days: 730))
          .toUtc();

      debugPrint("GOOGLE_CALENDAR: Descargando eventos de Google...");
      final existingEvents = await calendar.events.list(
        'primary',
        timeMin: minTime,
        timeMax: maxTime,
        singleEvents: true,
        orderBy: 'startTime',
        maxResults: 2500,
      );

      final googleItems = existingEvents.items ?? <cal.Event>[];

      // Claves de los eventos que ya están en Google. Se usan tanto las
      // extended properties (eventos creados por esta app) como título+fecha
      // para no duplicar los que se crearon antes de añadir la propiedad.
      final Set<String> clavesEnGoogle = {};
      for (final e in googleItems) {
        final appKey = e.extendedProperties?.private?['appHomeKey'];
        if (appKey != null && appKey.isNotEmpty) {
          clavesEnGoogle.add(appKey);
        }
        final fecha = _fechaDeGoogle(e);
        if (fecha != null) {
          clavesEnGoogle.add(_clave(e.summary ?? '', fecha));
        }
      }

      // 1. Subir los eventos locales que falten.
      int enviados = 0;
      for (final appEvent in eventosLocales) {
        final key = _clave(appEvent.titulo, appEvent.fecha);
        if (clavesEnGoogle.contains(key)) continue;

        debugPrint("GOOGLE_CALENDAR: Subiendo '${appEvent.titulo}'...");
        final googleEvent = _crearEventoGoogle(appEvent, key);
        await calendar.events.insert(googleEvent, 'primary');
        clavesEnGoogle.add(key);
        enviados++;
      }

      // 2. Importar los eventos de Google que no sean de esta app.
      final titulosLocalesPorDia = <String, Set<String>>{};
      for (final ev in eventosLocales) {
        titulosLocalesPorDia
            .putIfAbsent(_dia(ev.fecha), () => <String>{})
            .add(ev.titulo.trim().toLowerCase());
      }

      final importados = <AppEvent>[];
      int eliminados = 0;
      for (final e in googleItems) {
        if (e.extendedProperties?.private?['appHomeKey'] != null) {
          // Es un evento que subió esta app: ya se muestra desde los datos
          // locales y no hay que duplicarlo.
          continue;
        }
        final fecha = _fechaDeGoogle(e);
        if (fecha == null) continue;

        // Las versiones anteriores subían los eventos escolares como
        // "Cole: <nombre>" y el tipo en la descripción. Al cambiar el título
        // quedaban copias antiguas; se eliminan una sola vez.
        if (_esDuplicadoLegado(e, titulosLocalesPorDia)) {
          final id = e.id;
          if (id != null && id.isNotEmpty) {
            try {
              await calendar.events.delete('primary', id);
              eliminados++;
              debugPrint(
                "GOOGLE_CALENDAR: Duplicado antiguo eliminado: "
                "'${e.summary}' del ${_dia(fecha)}.",
              );
            } catch (err) {
              debugPrint(
                "GOOGLE_CALENDAR: No se pudo eliminar el duplicado $id: $err",
              );
            }
          }
          continue;
        }

        final titulo = (e.summary ?? '').trim();
        final descripcion = [
          if ((e.description ?? '').trim().isNotEmpty) e.description!.trim(),
          if ((e.location ?? '').trim().isNotEmpty) '📍 ${e.location!.trim()}',
        ].join(' · ');

        importados.add(AppEvent(
          titulo: titulo.isEmpty ? 'Evento de Google Calendar' : titulo,
          descripcion: descripcion.isEmpty ? 'Google Calendar' : descripcion,
          fecha: fecha,
          tipo: TipoEvento.calendario,
          icono: Icons.event_rounded,
          color: const Color(0xFF4C8BF5),
          googleId: e.id,
          desdeGoogle: true,
        ));
      }
      importados.sort((a, b) => a.fecha.compareTo(b.fecha));

      debugPrint(
        "GOOGLE_CALENDAR: ÉXITO. $enviados enviados, ${importados.length} "
        "importados, $eliminados duplicados eliminados.",
      );
      return ResultadoSincronizacion(
        eventosGoogle: importados,
        enviados: enviados,
        importados: importados.length,
        eliminados: eliminados,
      );
    } on cal.DetailedApiRequestError catch (e) {
      if (e.status == 401 || e.status == 403) {
        throw const CalendarAuthException(
          'Google Calendar ha rechazado el acceso. Vuelve a entrar con Google '
          'para renovar el permiso.',
        );
      }
      debugPrint("GOOGLE_CALENDAR ERROR: $e");
      rethrow;
    } catch (e) {
      debugPrint("GOOGLE_CALENDAR ERROR: $e");
      rethrow;
    } finally {
      authenticatedClient.close();
    }
  }

  cal.Event _crearEventoGoogle(AppEvent appEvent, String key) {
    final local = appEvent.fecha.toLocal();
    final esTodoElDia = local.hour == 0 && local.minute == 0 && local.second == 0;

    final googleEvent = cal.Event()
      ..summary = appEvent.titulo.trim()
      ..description = appEvent.descripcion.trim()
      ..extendedProperties = (cal.EventExtendedProperties()
        ..private = {'appHomeKey': key});

    if (esTodoElDia) {
      final dia = DateTime.utc(local.year, local.month, local.day);
      googleEvent.start = cal.EventDateTime()..date = dia;
      googleEvent.end = cal.EventDateTime()
        ..date = dia.add(const Duration(days: 1));
    } else {
      googleEvent.start = cal.EventDateTime()..dateTime = local.toUtc();
      googleEvent.end = cal.EventDateTime()
        ..dateTime = local.add(const Duration(hours: 1)).toUtc();
    }
    return googleEvent;
  }

  DateTime? _fechaDeGoogle(cal.Event evento) {
    final dateTime = evento.start?.dateTime;
    if (dateTime != null) return dateTime.toLocal();

    final date = evento.start?.date;
    if (date != null) {
      // La API devuelve las fechas de todo el día como UTC a medianoche;
      // se reconstruye la fecha local sin desplazarla de día.
      return DateTime(date.year, date.month, date.day);
    }
    return null;
  }

  bool _esDuplicadoLegado(
    cal.Event evento,
    Map<String, Set<String>> titulosLocalesPorDia,
  ) {
    final summary = (evento.summary ?? '').trim().toLowerCase();
    if (!summary.startsWith('cole: ')) return false;
    if (evento.extendedProperties?.private?['appHomeKey'] != null) return false;

    final fecha = _fechaDeGoogle(evento);
    if (fecha == null) return false;

    final descripcion = (evento.description ?? '').trim().toLowerCase();
    if (descripcion.isEmpty) return false;

    return titulosLocalesPorDia[_dia(fecha)]?.contains(descripcion) ?? false;
  }

  String _clave(String titulo, DateTime fecha) {
    final normalizado = titulo.trim().toLowerCase();
    // Las extended properties de Google admiten hasta 1024 caracteres.
    final recortado =
        normalizado.length > 200 ? normalizado.substring(0, 200) : normalizado;
    return '$recortado|${_dia(fecha)}';
  }

  String _dia(DateTime fecha) {
    final d = fecha.toLocal();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }
}

/// Cliente HTTP que inyecta el token de Google en cada petición.
class GoogleAuthClient extends http.BaseClient {
  final String _token;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._token);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_token';
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}
