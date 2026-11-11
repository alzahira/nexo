import 'package:flutter/foundation.dart';

import '../models/gestion/item_compra.dart';
import '../providers/auth_provider.dart';
import '../providers/usuario_provider.dart';
import '../services/google_tasks_service.dart';

/// Estado de la sincronización de la lista de la compra con Google Tasks.
///
/// La lista local es la fuente principal: lo que se marca, se añade o se borra
/// en la app se refleja en Google Tasks, y los productos creados directamente
/// en Google Tasks (o desde Google Calendar) se importan a la app.
class CompraSyncProvider extends ChangeNotifier {
  final AuthProvider _auth;
  late final GoogleTasksService _service =
      GoogleTasksService(_auth.obtenerTokenCalendario);

  bool _syncing = false;
  String? _error;
  bool _sinPermiso = false;
  DateTime? _lastSync;
  int _ultimosSubidos = 0;
  int _ultimosActualizados = 0;
  int _ultimosImportados = 0;

  bool get syncing => _syncing;
  String? get error => _error;
  bool get sinPermiso => _sinPermiso;
  DateTime? get lastSync => _lastSync;
  int get ultimosSubidos => _ultimosSubidos;
  int get ultimosActualizados => _ultimosActualizados;
  int get ultimosImportados => _ultimosImportados;

  CompraSyncProvider(this._auth);

  /// Sube/baja la lista y la guarda en Firestore si ha cambiado algo.
  Future<void> sincronizar(UsuarioProvider usuario) async {
    if (_syncing) return;
    _syncing = true;
    _error = null;
    notifyListeners();

    try {
      final resultado = await _service.sincronizar(usuario.listaCompra);

      if (resultado.importados.isNotEmpty) {
        await usuario.fusionarListaCompra(resultado.importados);
      }

      final idsNuevos = resultado.subidos > 0 || resultado.actualizados > 0;
      if (idsNuevos) {
        await usuario.guardarListaCompra();
      }

      _sinPermiso = false;
      _lastSync = DateTime.now();
      _ultimosSubidos = resultado.subidos;
      _ultimosActualizados = resultado.actualizados;
      _ultimosImportados = resultado.totalImportados;
    } on TareasAuthException catch (e) {
      _error = e.mensaje;
      _sinPermiso = true;
      debugPrint('COMPRA: sin permiso de Google Tasks: ${e.mensaje}');
    } catch (e) {
      _error = 'No se pudo sincronizar la lista con Google Tasks: $e';
      debugPrint('COMPRA: error de sincronización: $e');
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  /// Quita un producto de la lista y también su tarea de Google.
  Future<void> eliminarProducto(UsuarioProvider usuario, ItemCompra item) async {
    await usuario.removeItemCompra(item);
    try {
      await _service.eliminarTarea(item);
    } on TareasAuthException catch (e) {
      _error = e.mensaje;
      notifyListeners();
    } catch (e) {
      debugPrint('COMPRA: no se pudo borrar la tarea de Google: $e');
    }
  }
}
