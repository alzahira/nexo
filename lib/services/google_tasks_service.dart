import 'package:flutter/foundation.dart';
import 'package:googleapis/tasks/v1.dart' as gt;

import '../models/gestion/item_compra.dart';
import 'google_calendar_service.dart' show GoogleAuthClient;

/// Error de permisos con Google Tasks (sin sesión o token caducado).
class TareasAuthException implements Exception {
  final String mensaje;
  const TareasAuthException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Resultado de una sincronización de la lista de la compra.
class ResultadoTareas {
  /// Productos nuevos creados en Google Tasks.
  final int subidos;

  /// Tareas existentes a las que se les cambió el título, la cantidad o el
  /// estado (comprado / pendiente).
  final int actualizados;

  /// Tareas que existían en Google y no en la app.
  final List<ItemCompra> importados;

  const ResultadoTareas({
    required this.subidos,
    required this.actualizados,
    required this.importados,
  });

  int get totalImportados => importados.length;
}

/// Sincroniza la lista de la compra con una lista de Google Tasks.
///
/// Google Keep no tiene API pública, pero Google Tasks sí: la lista aparece
/// además dentro de Google Calendar y se puede compartir con la familia.
class GoogleTasksService {
  /// Nombre de la lista que se crea en la cuenta del usuario.
  static const String nombreLista = 'Nexo · Compra';

  final Future<String?> Function() _tokenProvider;

  GoogleTasksService(this._tokenProvider);

  /// Sube los productos locales que falten y devuelve los que solo están en
  /// Google. La lista local manda: si un producto se marca o se renombra en
  /// la app, se actualiza la tarea.
  Future<ResultadoTareas> sincronizar(List<ItemCompra> locales) async {
    debugPrint('GOOGLE_TASKS: Iniciando sincronización...');

    final token = await _tokenProvider();
    if (token == null || token.isEmpty) {
      throw const TareasAuthException(
        'Conecta tu cuenta de Google para sincronizar la lista de la compra.',
      );
    }

    final client = GoogleAuthClient(token);
    final api = gt.TasksApi(client);

    try {
      final listaId = await _idListaCompra(api);
      final respuesta = await api.tasks.list(
        listaId,
        showCompleted: true,
        showHidden: true,
        maxResults: 1000,
      );
      final tareas = respuesta.items ?? <gt.Task>[];
      debugPrint(
        'GOOGLE_TASKS: ${locales.length} productos locales, '
        '${tareas.length} tareas en Google.',
      );

      final porId = <String, gt.Task>{};
      final porTitulo = <String, gt.Task>{};
      for (final t in tareas) {
        final id = t.id;
        if (id == null || id.isEmpty) continue;
        porId[id] = t;
        final clave = _clave(t.title ?? '');
        if (clave.isNotEmpty) porTitulo.putIfAbsent(clave, () => t);
      }

      var subidos = 0;
      var actualizados = 0;
      final usados = <String>{};

      for (final item in locales) {
        final nombre = item.nombre.trim();
        if (nombre.isEmpty) continue;

        gt.Task? tarea;
        final idGuardado = item.googleTaskId;
        if (idGuardado != null && idGuardado.isNotEmpty) {
          tarea = porId[idGuardado];
        }
        tarea ??= porTitulo[_clave(nombre)];
        // Una tarea no puede representar dos productos distintos.
        if (tarea?.id != null && usados.contains(tarea!.id)) {
          tarea = null;
        }

        final estado = item.estaComprado ? 'completed' : 'needsAction';

        if (tarea == null) {
          final nueva = gt.Task()
            ..title = nombre
            ..notes = item.cantidadTexto
            ..status = estado;
          final creada = await api.tasks.insert(nueva, listaId);
          item.googleTaskId = creada.id;
          if ((creada.id ?? '').isNotEmpty) usados.add(creada.id!);
          subidos++;
          debugPrint("GOOGLE_TASKS: Subido '$nombre'.");
        } else {
          item.googleTaskId = tarea.id;
          if ((tarea.id ?? '').isNotEmpty) usados.add(tarea.id!);

          final cambios = gt.Task();
          var hayCambios = false;

          if ((tarea.title ?? '') != nombre) {
            cambios.title = nombre;
            hayCambios = true;
          }
          if ((tarea.notes ?? '') != item.cantidadTexto) {
            cambios.notes = item.cantidadTexto;
            hayCambios = true;
          }
          final estadoGoogle = tarea.status ?? 'needsAction';
          if (estadoGoogle != estado) {
            // Google pone la fecha de completado por su cuenta al cambiar el
            // estado, así que solo se manda `status`.
            cambios.status = estado;
            hayCambios = true;
          }

          if (hayCambios) {
            await api.tasks.patch(cambios, listaId, tarea.id!);
            actualizados++;
          }
        }
      }

      // Tareas nuevas hechas desde Google Tasks (o desde Calendar): se
      // incorporan a la lista de la app.
      final importados = <ItemCompra>[];
      for (final t in tareas) {
        final id = t.id;
        if (id == null || id.isEmpty || usados.contains(id)) continue;
        final titulo = (t.title ?? '').trim();
        if (titulo.isEmpty) continue;
        importados.add(_itemDesdeTarea(t));
      }

      debugPrint(
        'GOOGLE_TASKS: ÉXITO. $subidos subidos, $actualizados actualizados, '
        '${importados.length} importados.',
      );
      return ResultadoTareas(
        subidos: subidos,
        actualizados: actualizados,
        importados: importados,
      );
    } on gt.DetailedApiRequestError catch (e) {
      debugPrint(
        'GOOGLE_TASKS ERROR: ${e.status} ${e.message} '
        '${e.errors.map((d) => d.reason).join(',')}',
      );
      if (e.status == 401 || e.status == 403) {
        throw TareasAuthException(_mensajeDePermiso(e));
      }
      rethrow;
    } catch (e) {
      debugPrint('GOOGLE_TASKS ERROR: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Borra la tarea asociada a un producto (al quitarlo de la lista).
  Future<void> eliminarTarea(ItemCompra item) async {
    final id = item.googleTaskId;
    if (id == null || id.isEmpty) return;

    final token = await _tokenProvider();
    if (token == null || token.isEmpty) {
      throw const TareasAuthException(
        'Conecta tu cuenta de Google para borrar el producto de Google Tasks.',
      );
    }

    final client = GoogleAuthClient(token);
    final api = gt.TasksApi(client);
    try {
      final listaId = await _idListaCompra(api);
      await api.tasks.delete(listaId, id);
      debugPrint("GOOGLE_TASKS: Tarea '$id' eliminada.");
    } on gt.DetailedApiRequestError catch (e) {
      // Si ya no existe, no es un problema.
      if (e.status == 404 || e.status == 410) return;
      debugPrint('GOOGLE_TASKS: no se pudo borrar la tarea: $e');
      if (e.status == 401 || e.status == 403) {
        throw TareasAuthException(_mensajeDePermiso(e));
      }
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Devuelve el id de la lista "Nexo · Compra", creándola si no existe.
  Future<String> _idListaCompra(gt.TasksApi api) async {
    final listas = await api.tasklists.list(maxResults: 100);
    for (final lista in listas.items ?? <gt.TaskList>[]) {
      if ((lista.title ?? '').trim().toLowerCase() ==
          nombreLista.toLowerCase()) {
        final id = lista.id;
        if (id != null && id.isNotEmpty) return id;
      }
    }
    final creada = await api.tasklists.insert(gt.TaskList()..title = nombreLista);
    final id = creada.id;
    if (id == null || id.isEmpty) {
      throw const TareasAuthException(
        'No se pudo crear la lista de la compra en Google Tasks.',
      );
    }
    debugPrint("GOOGLE_TASKS: Lista '$nombreLista' creada.");
    return id;
  }

  ItemCompra _itemDesdeTarea(gt.Task tarea) {
    final titulo = (tarea.title ?? '').trim();
    final notas = (tarea.notes ?? '').trim();

    var cantidad = 1.0;
    var unidad = 'unidades';
    final match = RegExp(r'^(\d+(?:[.,]\d+)?)\s*(.*)$').firstMatch(notas);
    if (match != null) {
      cantidad = double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 1.0;
      final resto = (match.group(2) ?? '').trim();
      if (resto.isNotEmpty) unidad = resto;
    }

    return ItemCompra(
      nombre: titulo,
      cantidad: cantidad,
      unidad: unidad,
      estaComprado: (tarea.status ?? '') == 'completed',
      googleTaskId: tarea.id,
    );
  }

  String _clave(String titulo) => titulo.trim().toLowerCase();

  String _mensajeDePermiso(gt.DetailedApiRequestError e) {
    final razones = e.errors.map((d) => d.reason ?? '').join(' ');
    final mensaje = (e.message ?? '').trim();
    final todo = '$razones $mensaje'.toLowerCase();
    if (todo.contains('service_disabled') ||
        todo.contains('has not been used in project') ||
        todo.contains('is disabled')) {
      return 'La API de Google Tasks no está activada en el proyecto de '
          'Firebase. Actívala en console.cloud.google.com → APIs y servicios.';
    }
    if (todo.contains('insufficientpermissions') ||
        todo.contains('access_token_scope_insufficient') ||
        todo.contains('insufficient authentication scopes')) {
      return 'La cuenta no ha dado permiso a Google Tasks. Pulsa Conectar y '
          'acepta la casilla de las tareas.';
    }
    if (e.status == 401) {
      return 'La sesión de Google ha caducado. Pulsa Conectar para renovarla.';
    }
    return mensaje.isEmpty
        ? 'Google Tasks ha rechazado el acceso (${e.status}).'
        : 'Google Tasks ha rechazado el acceso: $mensaje';
  }
}
