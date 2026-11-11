import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../theme/app_theme.dart';

/// Rota la imagen respetando la orientación EXIF original.
///
/// Es de nivel superior para poder ejecutarse en un isolate aparte con
/// [compute] y no congelar la interfaz con fotos grandes.
Uint8List? _rotarFotoEnIsolate(({Uint8List bytes, int grados}) trabajo) {
  try {
    final decodificada = img.decodeImage(trabajo.bytes);
    if (decodificada == null) return null;
    final girada = img.copyRotate(
      img.bakeOrientation(decodificada),
      angle: trabajo.grados,
    );
    return Uint8List.fromList(img.encodeJpg(girada, quality: 92));
  } catch (e) {
    debugPrint('RECORTAR: no se pudo girar la imagen: $e');
    return null;
  }
}

/// Pantalla para encuadrar la foto de perfil: zoom, arrastre y giro.
///
/// Devuelve los bytes ya recortados (cuadrados) al cerrarse con "Usar foto".
class RecortarFotoScreen extends StatefulWidget {
  final Uint8List bytes;

  const RecortarFotoScreen({super.key, required this.bytes});

  @override
  State<RecortarFotoScreen> createState() => _RecortarFotoScreenState();
}

class _RecortarFotoScreenState extends State<RecortarFotoScreen> {
  final CropController _controller = CropController();

  late Uint8List _bytes = widget.bytes;
  int _version = 0;
  bool _recortando = false;
  bool _girando = false;
  bool _listo = false;

  /// Gira la imagen en pasos de 90° y vuelve a montar el editor.
  Future<void> _girar({required bool aLaDerecha}) async {
    if (_girando || _recortando) return;
    setState(() => _girando = true);
    final actual = _bytes;
    final grados = aLaDerecha ? 90 : -90;
    final girada = await compute(
      _rotarFotoEnIsolate,
      (bytes: actual, grados: grados),
    );
    if (!mounted) return;
    setState(() {
      if (girada != null) {
        _bytes = girada;
        _version++;
      }
      _girando = false;
      _listo = false;
    });
  }

  void _usar() {
    if (!_listo || _recortando) return;
    setState(() => _recortando = true);
    _controller.crop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Ajustar foto'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _listo && !_recortando ? _usar : null,
            child: const Text(
              'Usar',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: Text(
              'Mueve y pellizca la foto para encuadrar la cara. '
              'Puedes girarla con los botones de abajo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, height: 1.4),
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460, maxHeight: 460),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Crop(
                          key: ValueKey(_version),
                          image: _bytes,
                          controller: _controller,
                          aspectRatio: 1,
                          withCircleUi: true,
                          interactive: true,
                          fixCropRect: true,
                          baseColor: const Color(0xFF2E3A34),
                          maskColor: Colors.black.withValues(alpha: 0.55),
                          progressIndicator: const Center(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: AppTheme.accent,
                              ),
                            ),
                          ),
                          onStatusChanged: (estado) {
                            if (!mounted) return;
                            final listo = estado == CropStatus.ready;
                            if (listo != _listo) {
                              setState(() => _listo = listo);
                            }
                          },
                          onCropped: (resultado) {
                            if (!mounted) return;
                            if (resultado is CropSuccess) {
                              Navigator.pop(context, resultado.croppedImage);
                              return;
                            }
                            setState(() => _recortando = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No se pudo recortar la foto.'),
                                backgroundColor: AppTheme.dangerRed,
                              ),
                            );
                          },
                        ),
                        if (_girando || _recortando)
                          Container(
                            color: Colors.black.withValues(alpha: 0.35),
                            child: const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _botonRedondo(
                  icono: Icons.rotate_left_rounded,
                  tooltip: 'Girar a la izquierda',
                  onTap: () => _girar(aLaDerecha: false),
                ),
                const SizedBox(width: 18),
                _botonRedondo(
                  icono: Icons.rotate_right_rounded,
                  tooltip: 'Girar a la derecha',
                  onTap: () => _girar(aLaDerecha: true),
                ),
                const SizedBox(width: 18),
                _botonRedondo(
                  icono: Icons.zoom_out_map_rounded,
                  tooltip: 'Centrar de nuevo',
                  onTap: () {
                    setState(() {
                      _bytes = widget.bytes;
                      _version++;
                      _listo = false;
                    });
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _listo && !_recortando && !_girando ? _usar : null,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Usar esta foto'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonRedondo({
    required IconData icono,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppTheme.bgCard,
        shape: const CircleBorder(
          side: BorderSide(color: AppTheme.borderColor),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _girando || _recortando ? null : onTap,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(icono, color: AppTheme.accentGlow, size: 24),
          ),
        ),
      ),
    );
  }
}
