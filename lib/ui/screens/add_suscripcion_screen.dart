import 'package:flutter/material.dart';
import '../../models/gestion/suscripcion.dart';
import 'package:intl/intl.dart';

class AddSuscripcionScreen extends StatefulWidget {
  const AddSuscripcionScreen({super.key});

  @override
  State<AddSuscripcionScreen> createState() => _AddSuscripcionScreenState();
}

class _AddSuscripcionScreenState extends State<AddSuscripcionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  String _periodicidad = 'Mensual';
  DateTime _proximoCobro = DateTime.now();

  @override
  void dispose() {
    _nombreCtrl.dispose(); _precioCtrl.dispose(); super.dispose();
  }

  void _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _proximoCobro,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _proximoCobro = picked);
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, Suscripcion(
        nombre: _nombreCtrl.text,
        precio: double.tryParse(_precioCtrl.text) ?? 0.0,
        periodicidad: _periodicidad,
        fechaProximoCobro: _proximoCobro,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Suscripción'), backgroundColor: Colors.purple, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre (Ej: Netflix, Gym)', prefixIcon: Icon(Icons.subscriptions, color: Colors.purple)),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precioCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Precio (€)'),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _periodicidad,
                      decoration: const InputDecoration(labelText: 'Cobro'),
                      items: ['Mensual', 'Anual'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (v) => setState(() => _periodicidad = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: Colors.purple),
                title: const Text('Próximo Cobro'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_proximoCobro)),
                trailing: TextButton(onPressed: _seleccionarFecha, child: const Text('Cambiar', style: TextStyle(color: Colors.purple))),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardar,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: const Text('Registrar Gasto'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
