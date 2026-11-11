import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../models/common/app_event.dart';


class GoogleCalendarService {
  final GoogleSignIn _googleSignIn;

  GoogleCalendarService(this._googleSignIn);

  /// Sincroniza una lista de eventos con el calendario de Google.
  Future<void> syncEvents(List<AppEvent> events) async {
    debugPrint("GOOGLE_CALENDAR: Iniciando sincronización manual...");
    
    final GoogleSignInAccount? account = _googleSignIn.currentUser;
    if (account == null) {
      debugPrint("GOOGLE_CALENDAR ERROR: No hay usuario de Google activo en el plugin.");
      throw Exception("Inicia sesión con Google para sincronizar.");
    }

    // Solicitar permisos explícitamente si es necesario
    try {
      final bool granted = await _googleSignIn.requestScopes(['https://www.googleapis.com/auth/calendar']);
      if (!granted) {
        throw Exception("Permisos de calendario denegados por el usuario.");
      }
    } catch (e) {
      debugPrint("GOOGLE_CALENDAR: Aviso al solicitar scopes: $e");
    }

    // Obtenemos los headers de autenticación (Token de acceso)
    final Map<String, String> authHeaders = await account.authHeaders;
    final authenticatedClient = GoogleAuthClient(authHeaders);

    final calendar = cal.CalendarApi(authenticatedClient);
    
    try {
      final now = DateTime.now();
      final minTime = now.subtract(const Duration(days: 30)).toUtc();
      final maxTime = now.add(const Duration(days: 60)).toUtc();

      debugPrint("GOOGLE_CALENDAR: Fetching eventos existentes...");
      final existingEvents = await calendar.events.list(
        'primary',
        timeMin: minTime,
        timeMax: maxTime,
        singleEvents: true,
      );

      final Set<String> existingIdentifiers = {};
      if (existingEvents.items != null) {
        for (var e in existingEvents.items!) {
          final summary = e.summary?.trim().toLowerCase() ?? "";
          String? dateStr;
          if (e.start?.dateTime != null) {
            dateStr = e.start!.dateTime!.toIso8601String().split('T')[0];
          } else if (e.start?.date != null) {
            dateStr = e.start!.date!.toIso8601String().split('T')[0];
          }
          if (dateStr != null) {
            existingIdentifiers.add("${summary}_$dateStr");
          }
        }
      }

      int count = 0;
      for (var appEvent in events) {
        final dateStr = appEvent.fecha.toIso8601String().split('T')[0];
        final identifier = "${appEvent.titulo.trim().toLowerCase()}_$dateStr";

        if (!existingIdentifiers.contains(identifier)) {
          debugPrint("GOOGLE_CALENDAR: Añadiendo '${appEvent.titulo}'...");
          
          final googleEvent = cal.Event()
            ..summary = appEvent.titulo
            ..description = appEvent.descripcion
            ..start = (cal.EventDateTime()
              ..dateTime = appEvent.fecha.toUtc())
            ..end = (cal.EventDateTime()
              ..dateTime = appEvent.fecha.add(const Duration(hours: 1)).toUtc());

          await calendar.events.insert(googleEvent, 'primary');
          count++;
          existingIdentifiers.add(identifier);
        }
      }
      debugPrint("GOOGLE_CALENDAR: ÉXITO. $count nuevos eventos.");
    } catch (e) {
      debugPrint("GOOGLE_CALENDAR ERROR: $e");
      rethrow;
    } finally {
      authenticatedClient.close();
    }
  }
}

/// Cliente HTTP que inyecta los headers de Google Auth en cada petición
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
  
  @override
  void close() {
    _client.close();
    super.close();
  }
}
