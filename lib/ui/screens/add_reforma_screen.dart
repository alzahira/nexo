import 'package:flutter/material.dart';
import '../../models/hogar/reforma.dart';
import 'package:intl/intl.dart';

class AddReformaScreen extends StatefulWidget {
  const AddReformaScreen({super.key});

  @override
  State<AddReformaScreen> createState() => _AddReformaScreenState();
}

class _AddReformaScreenState extends State<AddReformaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _costeCtrl = TextEditingController();
  final _contrataCtrl = TextEditingController();
  DateTime _fechaFin = DateTime.now();

  @override
  void dispose() {
    _descCtrl.dispose(); _costeCtrl.dispose(); _contrataCtrl.dispose(); super.dispose();
  }

  void _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _fechaFin = picked);
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, Reforma(
        descripcion: _descCtrl.text,
        coste: double.tryParse(_costeCtrl.text) ?? 0.0,
        fechaFin: _fechaFin,
        contratista: _contrataCtrl.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Reforma'), backgroundColor: Colors.brown, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Descripción de la Obra', prefixIcon: Icon(Icons.handyman)), validator: (v) => v!.isEmpty ? 'Obligatorio' : null),
              const SizedBox(height: 15),
              TextFormField(controller: _contrataCtrl, decoration: const InputDecoration(labelText: 'Contratista / Empresa', prefixIcon: Icon(Icons.business_center)), validator: (v) => v!.isEmpty ? 'Obligatorio' : null),
              const SizedBox(height: 15),
              TextFormField(controller: _costeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Coste Total (€)', prefixIcon: Icon(Icons.euro)), validator: (v) => v!.isEmpty ? 'Obligatorio' : null),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month, color: Colors.brown),
                title: const Text('Fecha de Finalización'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_fechaFin)),
                trailing: TextButton(onPressed: _seleccionarFecha, child: const Text('Cambiar', style: TextStyle(color: Colors.brown))),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save), 
                label: const Text('Guardar'), 
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
