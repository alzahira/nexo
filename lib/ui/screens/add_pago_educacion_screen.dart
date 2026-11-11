import 'package:flutter/material.dart';
import '../../models/educacion/pago_educacion.dart';

class AddPagoEducacionScreen extends StatefulWidget {
  final PagoEducacion? pago;
  const AddPagoEducacionScreen({super.key, this.pago});

  @override
  State<AddPagoEducacionScreen> createState() => _AddPagoEducacionScreenState();
}

class _AddPagoEducacionScreenState extends State<AddPagoEducacionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _conceptoCtrl;
  String _periodicidad = 'Mensual';

  @override
  void initState() {
    super.initState();
    _conceptoCtrl = TextEditingController(text: widget.pago?.concepto ?? '');
    _periodicidad = widget.pago?.periodicidad ?? 'Mensual';
  }

  @override
  void dispose() {
    _conceptoCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, PagoEducacion(concepto: _conceptoCtrl.text, periodicidad: _periodicidad));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Pago Escolar'), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _conceptoCtrl,
                decoration: InputDecoration(
                  labelText: 'Concepto (Ej. Comedor, Seguro, Material)',
                  prefixIcon: const Icon(Icons.money, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: _periodicidad,
                decoration: InputDecoration(
                  labelText: 'Periodicidad del Cobro',
                  prefixIcon: const Icon(Icons.repeat, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: ['Único', 'Mensual', 'Trimestral', 'Anual'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _periodicidad = v!),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar Pago'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
                onPressed: _guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
