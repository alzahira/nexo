import 'dart:convert';
import 'dart:io';

import 'package:app_home/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('comprime una foto grande y devuelve un data URI pequeño', () async {
    final dir = await Directory.systemTemp.createTemp('apphome_foto_');
    final file = File('${dir.path}/foto.jpg');

    // Imagen de 1600x1200 con ruido para que no comprima demasiado.
    final image = img.Image(width: 1600, height: 1200);
    var seed = 12345;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        seed = (seed * 1103515245 + 12345) & 0x7fffffff;
        final r = seed & 0xFF;
        final g = (seed >> 8) & 0xFF;
        final b = (seed >> 16) & 0xFF;
        image.setPixelRgb(x, y, r, g, b);
      }
    }
    await file.writeAsBytes(img.encodeJpg(image, quality: 95));

    final url = await StorageService().subirFotoPerfil(file);
    expect(url.startsWith('data:image/jpeg;base64,'), isTrue);

    final bytes = base64Decode(url.substring(url.indexOf(',') + 1));
    expect(bytes.length, lessThanOrEqualTo(480 * 1024));
    expect(img.decodeImage(bytes), isNotNull);

    await dir.delete(recursive: true);
  });

  test('acepta una imagen PNG pequeña', () async {
    final dir = await Directory.systemTemp.createTemp('apphome_foto_png_');
    final file = File('${dir.path}/foto.png');
    final image = img.Image(width: 120, height: 120);
    img.fill(image, color: img.ColorRgb8(120, 160, 120));
    await file.writeAsBytes(img.encodePng(image));

    final url = await StorageService().subirFotoPerfil(file);
    expect(url.startsWith('data:image/jpeg;base64,'), isTrue);
    expect(img.decodeImage(base64Decode(url.split(',').last)), isNotNull);

    await dir.delete(recursive: true);
  });
}
