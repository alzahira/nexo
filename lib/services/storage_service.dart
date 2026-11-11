import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Error de procesado de foto con un mensaje apto para mostrar al usuario.
class FotoException implements Exception {
  final String mensaje;
  FotoException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Guarda las fotos de perfil dentro de Firestore, no en Cloud Storage.
///
/// El proyecto está en el plan gratuito y Firebase Storage exige facturación
/// (Blaze). Para que las fotos funcionen sin coste, se redimensionan y
/// comprimen y se guardan como `data:image/jpeg;base64,...` en el campo
/// `fotoUrl` de la persona (los documentos de Firestore admiten hasta 1 MiB).
class StorageService {
  /// Tamaño máximo del JPEG ya codificado (el base64 ocupa ~4/3).
  static const int _maxBytes = 480 * 1024;

  /// Procesa la foto y devuelve una URI de datos lista para guardar.
  ///
  /// Lanza [FotoException] con un mensaje claro si no se puede procesar.
  Future<String> subirFotoPerfil(File foto) async {
    final bytes = await foto.readAsBytes();
    if (bytes.isEmpty) {
      throw FotoException('La imagen está vacía.');
    }

    debugPrint('FOTO: imagen original ${(bytes.length / 1024).round()} KB');

    img.Image? decoded;
    try {
      decoded = img.decodeImage(bytes);
    } catch (e) {
      debugPrint('FOTO: decodeImage falló: $e');
      decoded = null;
    }

    // Si el decodificador no entiende el formato pero la imagen ya es
    // pequeña, se guarda tal cual. Flutter sabrá pintarla igualmente.
    if (decoded == null) {
      if (bytes.length <= _maxBytes) {
        debugPrint('FOTO: formato no decodificado, se guarda el original (${(bytes.length / 1024).round()} KB)');
        return 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }
      throw FotoException(
        'No se pudo leer la imagen (${(bytes.length / 1024).round()} KB). '
        'Prueba con una foto JPG o PNG más pequeña.',
      );
    }

    // Lado máximo 600 px
    var image = decoded;
    if (image.width > 600 || image.height > 600) {
      image = image.width >= image.height
          ? img.copyResize(image, width: 600)
          : img.copyResize(image, height: 600);
    }

    // Bajar calidad hasta que quepa
    var quality = 80;
    var out = img.encodeJpg(image, quality: quality);
    while (out.length > _maxBytes && quality > 30) {
      quality -= 10;
      out = img.encodeJpg(image, quality: quality);
    }

    // Si aún no cabe, reducir más el tamaño
    if (out.length > _maxBytes) {
      image = img.copyResize(image, width: 400);
      out = img.encodeJpg(image, quality: 60);
      quality = 60;
    }

    // Último intento: 300 px
    if (out.length > _maxBytes) {
      image = img.copyResize(image, width: 300);
      out = img.encodeJpg(image, quality: 50);
      quality = 50;
    }

    if (out.length > _maxBytes) {
      throw FotoException(
        'La imagen sigue siendo demasiado grande después de comprimirla '
        '(${(out.length / 1024).round()} KB).',
      );
    }

    debugPrint(
      'FOTO: guardada en Firestore (${(out.length / 1024).round()} KB, calidad $quality)',
    );
    return 'data:image/jpeg;base64,${base64Encode(out)}';
  }
}
