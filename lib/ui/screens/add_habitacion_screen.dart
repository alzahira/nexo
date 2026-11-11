import 'package:flutter/material.dart';
import '../../models/hogar/habitacion.dart';
import 'package:intl/intl.dart';

class AddHabitacionScreen extends StatefulWidget {
  const AddHabitacionScreen({super.key});

  @override
  State<AddHabitacionScreen> createState() => _AddHabitacionScreenState();
}

class _AddHabitacionScreenState extends State<AddHabitacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _tipoCtrl = TextEditingController();
  final _colorParedCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  DateTime? _ultimaVezPintado;

  @override
  void dispose() {
    _nombreCtrl.dispose(); _tipoCtrl.dispose(); _colorParedCtrl.dispose(); _notasCtrl.dispose();
    super.dispose();
  }

  void _seleccionarFecha(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _ultimaVezPintado = picked);
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, Habitacion(
        nombre: _nombreCtrl.text,
        tipo: _tipoCtrl.text,
        colorPared: _colorParedCtrl.text.isNotEmpty ? _colorParedCtrl.text : null,
        ultimaVezPintado: _ultimaVezPintado,
        notasMantenimiento: _notasCtrl.text.isNotEmpty ? _notasCtrl.text : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Habitación'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre (Ej. Dormitorio Matrimonio)', prefixIcon: Icon(Icons.meeting_room)), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 15),
              TextFormField(controller: _tipoCtrl, decoration: const InputDecoration(labelText: 'Tipo (Baño, Cocina, Exterior...)', prefixIcon: Icon(Icons.category)), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 20),
              
              const Divider(),
              const Text('Mantenimiento y Pintura', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
              const SizedBox(height: 10),

              TextFormField(controller: _colorParedCtrl, decoration: const InputDecoration(labelText: 'Código / Color de la Pared', prefixIcon: Icon(Icons.format_paint))),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month, color: Colors.indigo),
                title: const Text('Última vez que se pintó'),
                subtitle: Text(_ultimaVezPintado != null ? DateFormat('dd/MM/yyyy').format(_ultimaVezPintado!) : 'Nunca / Desconocido'),
                trailing: TextButton(onPressed: () => _seleccionarFecha(context), child: const Text('Cambiar', style: TextStyle(color: Colors.indigo))),
              ),
              const SizedBox(height: 15),
              TextFormField(controller: _notasCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Notas de mantenimiento', border: OutlineInputBorder(), prefixIcon: Icon(Icons.note))),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save), 
                label: const Text('Guardar Estancia'), 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)), 
                onPressed: _guardar
              )
            ]
          )
        )
      )
    );
  }
}
