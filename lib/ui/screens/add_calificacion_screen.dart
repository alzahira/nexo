import 'package:flutter/material.dart';
import '../../models/educacion/calificacion_materia.dart';

class AddCalificacionScreen extends StatefulWidget {
  const AddCalificacionScreen({super.key});
  @override
  State<AddCalificacionScreen> createState() => _AddCalificacionScreenState();
}

class _AddCalificacionScreenState extends State<AddCalificacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _asigCtrl = TextEditingController();
  final _notaCtrl = TextEditingController();

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, CalificacionMateria(
        asignatura: _asigCtrl.text, 
        notaFinal: double.parse(_notaCtrl.text.replaceAll(',', '.'))
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Nota Final'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16), 
        child: Form(
          key: _formKey, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _asigCtrl, 
                decoration: InputDecoration(
                  labelText: 'Asignatura / Materia',
                  prefixIcon: const Icon(Icons.book, color: Colors.green),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                ), 
                validator: (v) => v!.isEmpty ? 'Requerido' : null
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _notaCtrl, 
                keyboardType: const TextInputType.numberWithOptions(decimal: true), 
                decoration: InputDecoration(
                  labelText: 'Nota Numérica (Ej. 8.5)',
                  prefixIcon: const Icon(Icons.looks_one, color: Colors.green),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                ), 
                validator: (v) {
                  if (v!.isEmpty) return 'Requerido';
                  if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Número inválido';
                  return null;
                }
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar Calificación'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)), 
                onPressed: _guardar
              )
            ]
          )
        )
      )
    );
  }
}
