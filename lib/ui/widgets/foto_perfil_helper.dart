import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/usuarios/persona.dart';
import '../../providers/usuario_provider.dart';
import '../../services/storage_service.dart';

/// Cambia la foto de perfil desde cualquier pantalla que muestre una persona.
/// La imagen se comprime y se guarda como data URI en Firestore.
class FotoPerfilHelper {
  static Future<void> cambiar(BuildContext context, Persona persona) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 70,
      );

      if (pickedFile == null || !context.mounted) return;

      final prov = context.read<UsuarioProvider>();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preparando la foto...')),
      );

      final url = await StorageService().subirFotoPerfil(
        File(pickedFile.path),
      );
      persona.fotoUrl = url;

      await prov.notify(personaParaGuardar: persona);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto actualizada correctamente')),
        );
      }
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
}
