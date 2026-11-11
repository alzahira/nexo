import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/usuarios/persona.dart';
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
  DateTime _fechaNac = DateTime(
    DateTime.now().year - 30,
    DateTime.now().month,
    DateTime.now().day,
  );
  File? _imageFile;
  bool _subiendo = false;

  Future<void> _seleccionarFechaNacimiento() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNac,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _fechaNac = picked);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 70,
    );
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
        autovalidateMode: AutovalidateMode.onUserInteraction,
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

            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: InkWell(
                onTap: _seleccionarFechaNacimiento,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de nacimiento',
                    prefixIcon: Icon(Icons.cake_outlined),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_fechaNac),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const Icon(Icons.calendar_today_outlined, size: 18),
                    ],
                  ),
                ),
              ),
            ),

            _buildField(
              _dirCtrl,
              'Dirección',
              Icons.home,
              obligatorio: false,
            ),
            _buildField(
              _telCtrl,
              'Teléfono',
              Icons.phone,
              keyboard: TextInputType.phone,
              obligatorio: false,
            ),

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

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    bool obligatorio = true,
  }) {
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
        validator: obligatorio
            ? (value) => (value == null || value.trim().isEmpty)
                ? 'Campo obligatorio'
                : null
            : null,
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _subiendo = true);

    String? fotoUrl;

    // La foto se comprime y se guarda dentro de Firestore (sin Cloud Storage)
    if (_imageFile != null) {
      try {
        fotoUrl = await StorageService().subirFotoPerfil(_imageFile!);
      } on FotoException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('La foto no se pudo procesar: ${e.mensaje}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('La foto no se pudo procesar: $e')),
          );
        }
      }
    }

    if (!mounted) return;

    final nuevaPersona = Persona(
      nombre: _nombreCtrl.text.trim(),
      apellidos: _apellidosCtrl.text.trim(),
      dni: _dniCtrl.text.trim().toUpperCase(),
      direccion: _dirCtrl.text.trim(),
      telefono: _telCtrl.text.trim(),
      grupoSanguineo: _grupoSanguineo,
      fechaNacimiento: _fechaNac,
      fotoUrl: fotoUrl, // URL de Firebase Storage (o null si no hay foto)
    );
    Navigator.pop(context, nuevaPersona);
  }
}