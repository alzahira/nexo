import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/salud/prueba_medica.dart';
import '../theme/app_theme.dart';

class AddPruebaScreen extends StatefulWidget {
  final PruebaMedica? pruebaParaEditar;
  const AddPruebaScreen({super.key, this.pruebaParaEditar});

  @override
  State<AddPruebaScreen> createState() => _AddPruebaScreenState();
}

class _AddPruebaScreenState extends State<AddPruebaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tipoCtrl = TextEditingController();
  final _centroCtrl = TextEditingController();
  final _resultadoCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.pruebaParaEditar != null) {
      final p = widget.pruebaParaEditar!;
      _tipoCtrl.text = p.tipoPrueba;
      _centroCtrl.text = p.centro;
      _resultadoCtrl.text = p.resultado;
      _fecha = p.fecha;
      _imagePath = p.archivoURL;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool esEdicion = widget.pruebaParaEditar != null;
    return Scaffold(
      appBar: AppBar(title: Text(esEdicion ? 'Editar Prueba' : 'Nueva Prueba')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildInput(_tipoCtrl, 'Tipo de Prueba (Analítica, Rayos...)', Icons.science, obligatorio: true),
            _buildInput(_centroCtrl, 'Centro / Laboratorio', Icons.business),
            
            ListTile(
              tileColor: AppTheme.softSand,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Fecha de la Prueba'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_fecha)),
              trailing: const Icon(Icons.calendar_month, color: Colors.indigo),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _fecha, firstDate: DateTime(2000), lastDate: DateTime.now());
                if (d != null) setState(() => _fecha = d);
              },
            ),
            
            const SizedBox(height: 15),
            _buildInput(_resultadoCtrl, 'Resumen del Resultado', Icons.notes, maxLines: 3),
            
            const SizedBox(height: 25),
            const Text('Foto del Resultado / Informe', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildFotoPicker(),
            
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade700,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              ),
              onPressed: _guardar,
              child: Text(esEdicion ? 'Actualizar' : 'Guardar Prueba', 
                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool obligatorio = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
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
          border: Border.all(color: Colors.indigo.shade200)
        ),
        child: _imagePath == null 
          ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40, color: Colors.indigo), Text('Capturar Informe')])
          : ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(File(_imagePath!), fit: BoxFit.cover, width: double.infinity)),
      ),
    );
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, PruebaMedica(
        tipoPrueba: _tipoCtrl.text,
        centro: _centroCtrl.text,
        resultado: _resultadoCtrl.text,
        fecha: _fecha,
        archivoURL: _imagePath,
      ));
    }
  }
}