import 'package:flutter/foundation.dart';
import '../models/common/app_event.dart';
import '../providers/auth_provider.dart';
import '../services/google_calendar_service.dart';

/// Estado de la sincronización con Google Calendar.
///
/// Mantiene los eventos importados para que el calendario de Inicio los pueda
/// mostrar sin volver a pedirlos a la API en cada reconstrucción.
class CalendarSyncProvider extends ChangeNotifier {
  final AuthProvider _auth;
  late final GoogleCalendarService _service =
      GoogleCalendarService(_auth.obtenerTokenCalendario);

  List<AppEvent> _eventosGoogle = const [];
  bool _syncing = false;
  String? _error;
  bool _sinPermiso = false;
  DateTime? _lastSync;
  int _ultimosEnviados = 0;
  int _ultimosImportados = 0;
  int _ultimosEliminados = 0;

  String? _uid;

  CalendarSyncProvider(this._auth) {
    _uid = _auth.user?.uid;
    _auth.addListener(_alCambiarUsuario);
  }

  void _alCambiarUsuario() {
    final uid = _auth.user?.uid;
    if (uid == _uid) return;
    _uid = uid;
    _eventosGoogle = const [];
    _error = null;
    _sinPermiso = false;
    _lastSync = null;
    _ultimosEnviados = 0;
    _ultimosImportados = 0;
    _ultimosEliminados = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_alCambiarUsuario);
    super.dispose();
  }

  List<AppEvent> get eventosGoogle => _eventosGoogle;
  bool get syncing => _syncing;
  String? get error => _error;
  bool get sinPermiso => _sinPermiso;
  DateTime? get lastSync => _lastSync;
  int get ultimosEnviados => _ultimosEnviados;
  int get ultimosImportados => _ultimosImportados;
  int get ultimosEliminados => _ultimosEliminados;

  /// Sincroniza subida y bajada. En modo silencioso no muestra errores en
  /// pantalla; solo actualiza el estado para que Inicio pueda avisar.
  Future<void> sincronizar({
    required List<AppEvent> eventosLocales,
    bool silencioso = false,
  }) async {
    if (_syncing) return;
    _syncing = true;
    if (!silencioso) _error = null;
    notifyListeners();

    try {
      final resultado = await _service.sincronizar(eventosLocales);
      _eventosGoogle = resultado.eventosGoogle;
      _ultimosEnviados = resultado.enviados;
      _ultimosImportados = resultado.importados;
      _ultimosEliminados = resultado.eliminados;
      _lastSync = DateTime.now();
      _error = null;
      _sinPermiso = false;
    } on CalendarAuthException catch (e) {
      _sinPermiso = true;
      _error = e.mensaje;
    } catch (e) {
      _sinPermiso = false;
      _error = 'No se pudo sincronizar con Google Calendar. '
          'Comprueba tu conexión e inténtalo de nuevo.';
      debugPrint('CalendarSyncProvider: $e');
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  /// Se llama al cerrar sesión para no mostrar eventos de otra cuenta.
  void limpiar() {
    _eventosGoogle = const [];
    _error = null;
    _sinPermiso = false;
    _lastSync = null;
    _ultimosEnviados = 0;
    _ultimosImportados = 0;
    _ultimosEliminados = 0;
    notifyListeners();
  }
}
