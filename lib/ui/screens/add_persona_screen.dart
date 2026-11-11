import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/usuarios/persona.dart';
import '../../providers/usuario_provider.dart';
import '../../services/storage_service.dart';

class AddPersonaScreen extends StatefulWidget {
  const AddPersonaScreen({super.key});

  @override
  State<AddPersonaScreen> createState() => _AddPersonaScreenState();
}

class _AddPersonaScreenState extends State<AddPersonaScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nombreCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _dniCtrl = TextEditingController();
  final _dirCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  
  String _grupoSanguineo = 'A+';
  final DateTime _fechaNac = DateTime.now();
  File? _imageFile;
  bool _subiendo = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Miembro')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildField(_nombreCtrl, 'Nombre', Icons.person),
            _buildField(_apellidosCtrl, 'Apellidos', Icons.person_outline),
            _buildField(_dniCtrl, 'DNI', Icons.badge),
            _buildField(_dirCtrl, 'Dirección', Icons.home),
            _buildField(_telCtrl, 'Teléfono', Icons.phone, keyboard: TextInputType.phone),

            ListTile(
              leading: const Icon(Icons.bloodtype, color: Colors.red),
              title: const Text('Grupo Sanguíneo'),
              trailing: DropdownButton<String>(
                value: _grupoSanguineo,
                items: ['A+', 'A-', 'B+', 'B-', '0+', '0-', 'AB+', 'AB-'].map((v) {
                  return DropdownMenuItem<String>(value: v, child: Text(v));
                }).toList(),
                onChanged: (val) => setState(() => _grupoSanguineo = val!),
              ),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: _subiendo ? null : _guardar,
              child: _subiendo
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Guardar Miembro'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboard,
        validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _subiendo = true);

    String? fotoUrl;

    // Subir foto a Firebase Storage si se ha seleccionado una
    if (_imageFile != null) {
      final userId = context.read<UsuarioProvider>().userId ?? 'sin_usuario';
      final storage = StorageService();
      fotoUrl = await storage.subirFotoPerfil(userId, _dniCtrl.text.trim(), _imageFile!);
    }

    if (!mounted) return;

    final nuevaPersona = Persona(
      nombre: _nombreCtrl.text,
      apellidos: _apellidosCtrl.text,
      dni: _dniCtrl.text,
      direccion: _dirCtrl.text,
      telefono: _telCtrl.text,
      grupoSanguineo: _grupoSanguineo,
      fechaNacimiento: _fechaNac,
      fotoUrl: fotoUrl, // URL de Firebase Storage (o null si no hay foto)
    );
    Navigator.pop(context, nuevaPersona);
  }
}