import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/trabajo/contrato.dart';

class AddContratoScreen extends StatefulWidget {
  const AddContratoScreen({super.key});

  @override
  State<AddContratoScreen> createState() => _AddContratoScreenState();
}

class _AddContratoScreenState extends State<AddContratoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tipoCtrl = TextEditingController();
  final _identificadorCtrl = TextEditingController();
  final _archivoURLCtrl = TextEditingController();
  DateTime _fechaInicio = DateTime.now();
  DateTime? _fechaFin;

  @override
  void dispose() {
    _tipoCtrl.dispose(); _identificadorCtrl.dispose(); _archivoURLCtrl.dispose();
    super.dispose();
  }

  void _selectFileModeDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _fechaInicio : (_fechaFin ?? DateTime.now()),
      firstDate: DateTime(1980),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _fechaInicio = picked;
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, Contrato(
        tipoContrato: _tipoCtrl.text,
        identificadorContrato: _identificadorCtrl.text,
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
        archivoURL: _archivoURLCtrl.text.isNotEmpty ? _archivoURLCtrl.text : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Contrato'), backgroundColor: Colors.brown, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _tipoCtrl, decoration: const InputDecoration(labelText: 'Tipo (Ej. Indefinido, Fijo Discontinuo)', prefixIcon: Icon(Icons.description)), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 15),
              TextFormField(controller: _identificadorCtrl, decoration: const InputDecoration(labelText: 'Identificador / Referencia', prefixIcon: Icon(Icons.numbers))),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.date_range, color: Colors.brown),
                title: const Text('Fecha de Inicio'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_fechaInicio)),
                trailing: TextButton(onPressed: () => _selectFileModeDate(context, true), child: const Text('Cambiar', style: TextStyle(color: Colors.brown))),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_busy, color: Colors.brown),
                title: const Text('Fecha de Fin (Opcional)'),
                subtitle: Text(_fechaFin != null ? DateFormat('dd/MM/yyyy').format(_fechaFin!) : 'No definida'),
                trailing: TextButton(onPressed: () => _selectFileModeDate(context, false), child: const Text('Cambiar', style: TextStyle(color: Colors.brown))),
              ),
              const SizedBox(height: 15),
              TextFormField(controller: _archivoURLCtrl, decoration: const InputDecoration(labelText: 'URL de Respaldo PDF', prefixIcon: Icon(Icons.link))),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save), 
                label: const Text('Guardar Contrato'), 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)), 
                onPressed: _guardar
              )
            ]
          )
        )
      )
    );
  }
}
