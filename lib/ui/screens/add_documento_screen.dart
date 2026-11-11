import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/usuarios/documento_identidad.dart';
import '../theme/app_theme.dart';

class AddDocumentoScreen extends StatefulWidget {
  const AddDocumentoScreen({super.key});

  @override
  State<AddDocumentoScreen> createState() => _AddDocumentoScreenState();
}

class _AddDocumentoScreenState extends State<AddDocumentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numCtrl = TextEditingController();
  
  String _tipoDoc = 'DNI';
  final DateTime _fExpedicion = DateTime.now();
  DateTime _fCaducidad = DateTime.now().add(const Duration(days: 365 * 10));
  File? _docImage;

  Future<void> _hacerFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera); // Directo a cámara
    if (pickedFile != null) {
      setState(() => _docImage = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Documento')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Botón para "Escanear" (Foto)
            GestureDetector(
              onTap: _hacerFoto,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: AppTheme.softSand,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: _docImage == null 
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.camera_alt, size: 50, color: Colors.blue), Text('Hacer foto al documento')],
                    )
                  : Image.file(_docImage!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            
            // Tipo de Documento
            DropdownButtonFormField<String>(
              initialValue: _tipoDoc,
              decoration: const InputDecoration(labelText: 'Tipo de Documento', border: OutlineInputBorder()),
              items: ['DNI', 'Pasaporte', 'Carnet Conducir', 'Tarjeta Sanitaria'].map((e) => 
                DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _tipoDoc = val!),
            ),
            const SizedBox(height: 15),

            // Número
            TextFormField(
              controller: _numCtrl,
              decoration: const InputDecoration(labelText: 'Número / ID', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Introduce el número' : null,
            ),
            const SizedBox(height: 15),

            // Fechas
            ListTile(
              title: const Text('Fecha Caducidad'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_fCaducidad)),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final date = await showDatePicker(
                  context: context, 
                  initialDate: _fCaducidad, 
                  firstDate: DateTime.now(), 
                  lastDate: DateTime(2050)
                );
                if (date != null) setState(() => _fCaducidad = date);
              },
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final nuevoDoc = DocumentoIdentidad(
                    tipoDocumento: _tipoDoc,
                    numero: _numCtrl.text,
                    fechaExpedicion: _fExpedicion,
                    fechaCaducidad: _fCaducidad,
                    archivoURL: _docImage?.path,
                  );
                  Navigator.pop(context, nuevoDoc);
                }
              },
              child: const Text('Guardar Documento'),
            )
          ],
        ),
      ),
    );
  }
}