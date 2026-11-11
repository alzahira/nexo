import 'package:flutter/material.dart';
import '../../models/educacion/tarea.dart';
import 'package:intl/intl.dart';

class AddTareaScreen extends StatefulWidget {
  final Tarea? tareaExistente;
  const AddTareaScreen({super.key, this.tareaExistente});

  @override
  State<AddTareaScreen> createState() => _AddTareaScreenState();
}

class _AddTareaScreenState extends State<AddTareaScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _tituloCtrl;
  late TextEditingController _descCtrl;
  late DateTime _fechaEntrega;
  bool _entregado = false;

  @override
  void initState() {
    super.initState();
    final t = widget.tareaExistente;
    _tituloCtrl = TextEditingController(text: t?.titulo ?? '');
    _descCtrl = TextEditingController(text: t?.descripcion ?? '');
    _fechaEntrega = t?.fechaEntrega ?? DateTime.now().add(const Duration(days: 1));
    _entregado = t?.entregado ?? false;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaEntrega,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (fecha != null && context.mounted) {
      setState(() {
        _fechaEntrega = DateTime(fecha.year, fecha.month, fecha.day, 23, 59); // Fin del día
      });
    }
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final nuevaTarea = Tarea(
        titulo: _tituloCtrl.text,
        fechaEntrega: _fechaEntrega,
        descripcion: _descCtrl.text,
        entregado: _entregado,
      );
      Navigator.pop(context, nuevaTarea);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tareaExistente == null ? 'Añadir Tarea' : 'Editar Tarea'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloCtrl,
                decoration: InputDecoration(
                  labelText: 'Título de la Tarea',
                  prefixIcon: const Icon(Icons.title, color: Colors.indigo),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Introduce un título' : null,
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: () => _seleccionarFecha(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha de Entrega',
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.indigo),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy').format(_fechaEntrega), style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Descripción / Detalles',
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.notes, color: Colors.indigo),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 15),
              SwitchListTile(
                title: const Text('¿Tarea Entregada?'),
                subtitle: const Text('Marca si el alumno ya ha finalizado y entregado esta tarea.'),
                value: _entregado,
                activeThumbColor: Colors.orange,
                onChanged: (bool value) {
                  setState(() {
                    _entregado = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar Tarea'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
