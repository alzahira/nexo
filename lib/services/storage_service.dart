import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube una foto de perfil y devuelve la URL pública de descarga.
  Future<String?> subirFotoPerfil(String userId, String dni, File foto) async {
    try {
      final ref = _storage.ref().child('fotos_perfil/$userId/$dni.jpg');
      final task = await ref.putFile(foto);
      final url = await task.ref.getDownloadURL();
      debugPrint("STORAGE: Foto subida correctamente -> $url");
      return url;
    } catch (e) {
      debugPrint("STORAGE ERROR: $e");
      return null;
    }
  }

  /// Elimina la foto de un usuario de Storage.
  Future<void> eliminarFotoPerfil(String userId, String dni) async {
    try {
      await _storage.ref().child('fotos_perfil/$userId/$dni.jpg').delete();
    } catch (e) {
      debugPrint("STORAGE: No se pudo eliminar foto (puede que no exista): $e");
    }
  }
}
