import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/salud/vacuna.dart';
import '../theme/app_theme.dart';

class AddVacunaScreen extends StatefulWidget {
  final Vacuna? vacunaParaEditar;
  const AddVacunaScreen({super.key, this.vacunaParaEditar});

  @override
  State<AddVacunaScreen> createState() => _AddVacunaScreenState();
}

class _AddVacunaScreenState extends State<AddVacunaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _dosisCtrl = TextEditingController();
  final _labCtrl = TextEditingController(); // Laboratorio/Lote
  DateTime _fecha = DateTime.now();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.vacunaParaEditar != null) {
      final v = widget.vacunaParaEditar!;
      _nombreCtrl.text = v.nombre;
      _dosisCtrl.text = v.dosis;
      _labCtrl.text = v.laboratorio;
      _fecha = v.fechaPuesta;
      _imagePath = v.fotoPath;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool esEdicion = widget.vacunaParaEditar != null;
    return Scaffold(
      appBar: AppBar(title: Text(esEdicion ? 'Editar Vacuna' : 'Nueva Vacuna')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildInput(_nombreCtrl, 'Nombre de la Vacuna', Icons.vaccines, obligatorio: true),
            _buildInput(_dosisCtrl, 'Dosis (ej: 1ª, Refuerzo...)', Icons.numbers),
            _buildInput(_labCtrl, 'Laboratorio / Lote', Icons.factory),
            
            ListTile(
              tileColor: AppTheme.softSand,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Fecha de Administración'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_fecha)),
              trailing: const Icon(Icons.calendar_today, color: Colors.purple),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _fecha, firstDate: DateTime(1950), lastDate: DateTime.now());
                if (d != null) setState(() => _fecha = d);
              },
            ),
            
            const SizedBox(height: 25),
            const Text('Foto del Carnet / Justificante', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildFotoPicker(),
            
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              ),
              onPressed: _guardar,
              child: Text(esEdicion ? 'Actualizar' : 'Registrar Vacuna', 
                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool obligatorio = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => obligatorio && (v == null || v.isEmpty) ? 'Campo requerido' : null,
      ),
    );
  }

  Widget _buildFotoPicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await ImagePicker().pickImage(source: ImageSource.camera);
        if (picked != null) setState(() => _imagePath = picked.path);
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppTheme.softSand,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.purple.shade200)
        ),
        child: _imagePath == null 
          ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40, color: Colors.purple), Text('Foto del carnet')])
          : ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(File(_imagePath!), fit: BoxFit.cover, width: double.infinity)),
      ),
    );
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, Vacuna(
        nombre: _nombreCtrl.text,
        dosis: _dosisCtrl.text,
        laboratorio: _labCtrl.text,
        fechaPuesta: _fecha,
        fotoPath: _imagePath,
      ));
    }
  }
}