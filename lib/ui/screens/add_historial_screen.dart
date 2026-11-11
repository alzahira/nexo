import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/salud/visita_historial.dart';
import '../theme/app_theme.dart';

class AddHistorialScreen extends StatefulWidget {
  final VisitaHistorial? itemParaEditar;
  const AddHistorialScreen({super.key, this.itemParaEditar});

  @override
  State<AddHistorialScreen> createState() => _AddHistorialScreenState();
}

class _AddHistorialScreenState extends State<AddHistorialScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores basados en tu clase VisitaHistorial
  final _incidenciaCtrl = TextEditingController();
  final _centroCtrl = TextEditingController();
  final _valoracionCtrl = TextEditingController();
  final _tratamientoCtrl = TextEditingController();
  
  DateTime _fecha = DateTime.now();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.itemParaEditar != null) {
      final v = widget.itemParaEditar!;
      _incidenciaCtrl.text = v.incidencia;
      _centroCtrl.text = v.centroSalud;
      _valoracionCtrl.text = v.valoracion;
      _tratamientoCtrl.text = v.tratamientoRecomendado;
      _fecha = v.fecha;
      _imagePath = v.fotoInforme;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.itemParaEditar == null ? 'Nueva Visita' : 'Editar Visita')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildInput(_incidenciaCtrl, 'Incidencia / Motivo', Icons.description),
            _buildInput(_centroCtrl, 'Centro de Salud', Icons.local_hospital),
            
            ListTile(
              tileColor: AppTheme.softSand,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: const Text('Fecha de la Visita'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_fecha)),
              trailing: const Icon(Icons.calendar_month, color: Colors.teal),
              onTap: _seleccionarFecha,
            ),
            
            const SizedBox(height: 20),
            _buildInput(_valoracionCtrl, 'Valoración Médica', Icons.rate_review, maxLines: 3),
            _buildInput(_tratamientoCtrl, 'Tratamiento Recomendado', Icons.medication, maxLines: 2),
            
            const Divider(height: 40),
            const Text('Adjuntar Informe (Opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildFotoPicker(),
            
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              ),
              onPressed: _guardar,
              child: const Text('Guardar Historial', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Widgets auxiliares para mantener el código limpio
  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
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
      ),
    );
  }

  Widget _buildFotoPicker() {
    return GestureDetector(
      onTap: () async {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
        if (pickedFile != null) setState(() => _imagePath = pickedFile.path);
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppTheme.softSand,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.teal.shade200)
        ),
        child: _imagePath == null 
          ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40, color: Colors.teal), Text('Hacer foto al informe')])
          : ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(File(_imagePath!), fit: BoxFit.cover, width: double.infinity)),
      ),
    );
  }

  void _seleccionarFecha() async {
    final d = await showDatePicker(context: context, initialDate: _fecha, firstDate: DateTime(2000), lastDate: DateTime.now());
    if (d != null) setState(() => _fecha = d);
  }

  void _guardar() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, VisitaHistorial(
        fecha: _fecha,
        incidencia: _incidenciaCtrl.text,
        centroSalud: _centroCtrl.text,
        valoracion: _valoracionCtrl.text,
        tratamientoRecomendado: _tratamientoCtrl.text,
        fotoInforme: _imagePath,
      ));
    }
  }
}