import 'package:flutter/material.dart';
import '../../models/educacion/curso_academico.dart';

class AddCursoScreen extends StatefulWidget {
  final CursoAcademico? cursoExistente;
  const AddCursoScreen({super.key, this.cursoExistente});

  @override
  State<AddCursoScreen> createState() => _AddCursoScreenState();
}

class _AddCursoScreenState extends State<AddCursoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl, _nivelCtrl, _centroCtrl;

  @override
  void initState() {
    super.initState();
    final c = widget.cursoExistente;
    _nombreCtrl = TextEditingController(text: c?.nombreCurso ?? '');
    _nivelCtrl = TextEditingController(text: c?.nivel ?? '');
    _centroCtrl = TextEditingController(text: c?.centro ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose(); 
    _nivelCtrl.dispose(); 
    _centroCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, CursoAcademico(
        nombreCurso: _nombreCtrl.text,
        nivel: _nivelCtrl.text,
        centro: _centroCtrl.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Curso / Año'), backgroundColor: Colors.orange, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreCtrl, 
                decoration: InputDecoration(
                  labelText: 'Nombre (Ej. 3º ESO, 1º Bachillerato)',
                  prefixIcon: const Icon(Icons.school, color: Colors.orange),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                ), 
                validator: (v) => v!.isEmpty ? 'Obligatorio' : null
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _nivelCtrl, 
                decoration: InputDecoration(
                  labelText: 'Nivel Educativo (Ej. Básica, Universidad)',
                  prefixIcon: const Icon(Icons.stairs, color: Colors.orange),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                ), 
                validator: (v) => v!.isEmpty ? 'Obligatorio' : null
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _centroCtrl, 
                decoration: InputDecoration(
                  labelText: 'Centro o Instituto',
                  prefixIcon: const Icon(Icons.business, color: Colors.orange),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                )
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save), 
                label: const Text('Guardar Curso'), 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)), 
                onPressed: _guardar
              )
            ]
          )
        )
      )
    );
  }
}
