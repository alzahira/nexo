import 'package:flutter/material.dart';
import '../../models/hogar/electrodomestico.dart';
import 'package:intl/intl.dart';

class AddElectrodomesticoScreen extends StatefulWidget {
  const AddElectrodomesticoScreen({super.key});

  @override
  State<AddElectrodomesticoScreen> createState() => _AddElectrodomesticoScreenState();
}

class _AddElectrodomesticoScreenState extends State<AddElectrodomesticoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _marcaCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _mesesGarantiaCtrl = TextEditingController(text: '36'); // Por ley en España suelen ser 3 años
  final _ubicacionCtrl = TextEditingController();
  DateTime _fechaCompra = DateTime.now();

  @override
  void dispose() {
    _nombreCtrl.dispose(); _marcaCtrl.dispose(); _precioCtrl.dispose();
    _mesesGarantiaCtrl.dispose(); _ubicacionCtrl.dispose(); super.dispose();
  }

  void _seleccionarFecha(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaCompra,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _fechaCompra = picked);
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, Electrodomestico(
        nombre: _nombreCtrl.text,
        marca: _marcaCtrl.text,
        fechaCompra: _fechaCompra,
        mesesGarantia: int.tryParse(_mesesGarantiaCtrl.text) ?? 36,
        precio: double.tryParse(_precioCtrl.text) ?? 0.0,
        ubicacion: _ubicacionCtrl.text.isNotEmpty ? _ubicacionCtrl.text : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Electrodomést.', style: TextStyle(fontSize: 18)), backgroundColor: Colors.orange, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre / Aparato', prefixIcon: Icon(Icons.tv)), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 15),
              TextFormField(controller: _marcaCtrl, decoration: const InputDecoration(labelText: 'Marca y Modelo', prefixIcon: Icon(Icons.branding_watermark)), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 15),
              TextFormField(controller: _ubicacionCtrl, decoration: const InputDecoration(labelText: 'Ubicación (Ej: Cocina, Salón)', prefixIcon: Icon(Icons.location_on))),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _precioCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Precio (€)', prefixIcon: Icon(Icons.euro)))),
                  const SizedBox(width: 15),
                  Expanded(child: TextFormField(controller: _mesesGarantiaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Garantía (Meses)', prefixIcon: Icon(Icons.shield)))),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month, color: Colors.orange),
                title: const Text('Fecha de Compra'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_fechaCompra)),
                trailing: TextButton(onPressed: () => _seleccionarFecha(context), child: const Text('Cambiar', style: TextStyle(color: Colors.orange))),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save), 
                label: const Text('Guardar Enser'), 
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
