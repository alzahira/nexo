import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/usuarios/persona.dart';
import '../../providers/usuario_provider.dart';
import '../../services/storage_service.dart';
import '../screens/recortar_foto_screen.dart';
import '../theme/app_theme.dart';

enum _FuenteFoto { galeria, camara, quitar }

/// Cambia la foto de perfil desde cualquier pantalla que muestre una persona.
///
/// Flujo: elegir origen (galería/cámara) → encuadrar y girar → comprimir →
/// guardar como data URI en Firestore. También permite quitar la foto.
class FotoPerfilHelper {
  static Future<void> cambiar(BuildContext context, Persona persona) async {
    final tieneFoto = (persona.fotoUrl ?? '').isNotEmpty;
    final origen = await _elegirOrigen(context, tieneFoto: tieneFoto);
    if (origen == null || !context.mounted) return;

    if (origen == _FuenteFoto.quitar) {
      await _quitar(context, persona);
      return;
    }

    try {
      final pickedFile = await ImagePicker().pickImage(
        source: origen == _FuenteFoto.camara
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );

      if (pickedFile == null || !context.mounted) return;

      final bytes = await pickedFile.readAsBytes();
      if (!context.mounted) return;

      // Encuadre: zoom, arrastre y giro antes de guardar.
      final recortada = await Navigator.of(context).push<Uint8List>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => RecortarFotoScreen(bytes: bytes),
        ),
      );
      if (recortada == null || !context.mounted) return;

      final prov = context.read<UsuarioProvider>();
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Preparando la foto...')),
      );

      final url = await StorageService().subirFotoPerfilBytes(recortada);
      persona.fotoUrl = url;

      await prov.notify(personaParaGuardar: persona);

      if (!context.mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(content: Text('Foto actualizada correctamente')),
      );
    } on FotoException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar la foto: ${e.mensaje}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la foto: $e')),
        );
      }
    }
  }

  /// Hoja inferior con los orígenes disponibles.
  static Future<_FuenteFoto?> _elegirOrigen(
    BuildContext context, {
    required bool tieneFoto,
  }) {
    // image_picker no tiene cámara en escritorio: se oculta la opción.
    final hayCamara = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    return showModalBottomSheet<_FuenteFoto>(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Foto de perfil',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppTheme.accentGlow),
              title: const Text('Elegir de la galería'),
              subtitle: const Text('Podrás recortarla y girarla'),
              onTap: () => Navigator.pop(context, _FuenteFoto.galeria),
            ),
            if (hayCamara)
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded,
                    color: AppTheme.accentGlow),
                title: const Text('Hacer una foto'),
                onTap: () => Navigator.pop(context, _FuenteFoto.camara),
              ),
            if (tieneFoto)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: AppTheme.dangerRed),
                title: const Text(
                  'Quitar la foto',
                  style: TextStyle(color: AppTheme.dangerRed),
                ),
                onTap: () => Navigator.pop(context, _FuenteFoto.quitar),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Future<void> _quitar(BuildContext context, Persona persona) async {
    final prov = context.read<UsuarioProvider>();
    final messenger = ScaffoldMessenger.of(context);
    persona.fotoUrl = null;
    await prov.notify(personaParaGuardar: persona);
    if (!context.mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Foto eliminada. Se usará la inicial.')),
    );
  }
}
