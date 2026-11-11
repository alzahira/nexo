import 'package:flutter/material.dart';
import '../../models/hogar/propiedad.dart';
import 'package:intl/intl.dart';

class AddPropiedadScreen extends StatefulWidget {
  const AddPropiedadScreen({super.key});

  @override
  State<AddPropiedadScreen> createState() => _AddPropiedadScreenState();
}

class _AddPropiedadScreenState extends State<AddPropiedadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aliasCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _refCatastralCtrl = TextEditingController();
  final _ibiCtrl = TextEditingController();
  final _valorCompraCtrl = TextEditingController();
  DateTime? _fechaCompra;

  @override
  void dispose() {
    _aliasCtrl.dispose(); _direccionCtrl.dispose(); _refCatastralCtrl.dispose();
    _ibiCtrl.dispose(); _valorCompraCtrl.dispose(); super.dispose();
  }

  void _seleccionarFecha(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _fechaCompra = picked);
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, Propiedad(
        alias: _aliasCtrl.text,
        direccion: _direccionCtrl.text,
        referenciaCatastral: _refCatastralCtrl.text,
        ibi: double.tryParse(_ibiCtrl.text) ?? 0.0,
        valorCompra: double.tryParse(_valorCompraCtrl.text),
        fechaCompra: _fechaCompra,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Propiedad'), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _aliasCtrl, decoration: const InputDecoration(labelText: 'Alias (Ej. Mi Casa, Apartamento)', prefixIcon: Icon(Icons.label)), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 15),
              TextFormField(controller: _direccionCtrl, decoration: const InputDecoration(labelText: 'Dirección Completa', prefixIcon: Icon(Icons.location_on)), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 15),
              TextFormField(controller: _refCatastralCtrl, decoration: const InputDecoration(labelText: 'Referencia Catastral', prefixIcon: Icon(Icons.map))),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _ibiCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'IBI Anual (€)', prefixIcon: Icon(Icons.receipt_long)))),
                  const SizedBox(width: 15),
                  Expanded(child: TextFormField(controller: _valorCompraCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valor de Compra (€)'))),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: Colors.teal),
                title: const Text('Fecha de Compra'),
                subtitle: Text(_fechaCompra != null ? DateFormat('dd/MM/yyyy').format(_fechaCompra!) : 'No definida'),
                trailing: TextButton(onPressed: () => _seleccionarFecha(context), child: const Text('Seleccionar', style: TextStyle(color: Colors.teal))),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save), 
                label: const Text('Registrar Inmueble'), 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)), 
                onPressed: _guardar
              )
            ]
          )
        )
      )
    );
  }
}
