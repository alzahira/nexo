import 'dart:io';

import 'package:flutter/foundation.dart';

RandomAccessFile? _lock;

/// Intenta tomar el bloqueo exclusivo de la app en escritorio.
///
/// Devuelve `false` si ya hay otra instancia abierta (el bloqueo lo tiene
/// otro proceso). En ese caso hay que salir antes de inicializar Firebase,
/// porque dos instancias no pueden compartir la caché de Firestore.
Future<bool> adquirirInstanciaUnica() async {
  if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    return true;
  }
  try {
    final base = Platform.environment['LOCALAPPDATA'] ??
        Platform.environment['APPDATA'] ??
        Directory.systemTemp.path;
    final dir = Directory('$base${Platform.pathSeparator}AppHome');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final raf = await File(
      '${dir.path}${Platform.pathSeparator}apphome.lock',
    ).open(mode: FileMode.append);
    try {
      await raf.lock(FileLock.exclusive);
      _lock = raf;
      return true;
    } on FileSystemException {
      await raf.close();
      return false;
    }
  } catch (e) {
    // Si algo falla al comprobar, es mejor dejar arrancar que bloquear la app.
    debugPrint('Instancia única: no se pudo comprobar ($e)');
    return true;
  }
}

/// Cierra la aplicación desde el aviso de "ya está abierto".
void cerrarAplicacion() => exit(0);

/// Libera el bloqueo (el sistema también lo hace al terminar el proceso).
void liberarInstanciaUnica() {
  try {
    _lock?.unlock();
    _lock?.close();
  } catch (_) {
    // Ignorado: al salir del proceso da igual.
  }
  _lock = null;
}
