import 'dart:typed_data';

import 'package:app_home/ui/screens/recortar_foto_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  testWidgets('la pantalla de recorte se monta con el botón de usar foto',
      (tester) async {
    final imagen = img.Image(width: 300, height: 200);
    img.fill(imagen, color: img.ColorRgb8(200, 120, 90));
    final bytes = Uint8List.fromList(img.encodePng(imagen));

    await tester.pumpWidget(
      MaterialApp(home: RecortarFotoScreen(bytes: bytes)),
    );
    // Se dejan pasar unos frames para que el editor cargue la imagen.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Ajustar foto'), findsOneWidget);
    expect(find.text('Usar esta foto'), findsOneWidget);
    expect(find.byIcon(Icons.rotate_left_rounded), findsOneWidget);
    expect(find.byIcon(Icons.rotate_right_rounded), findsOneWidget);

    // Hasta que la imagen está lista el botón está desactivado.
    final boton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(boton.onPressed, isNull);
  });
}
