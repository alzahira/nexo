import 'package:flutter/material.dart';
import '../../models/gestion/suministro.dart';

class AddSuministroScreen extends StatefulWidget {
  const AddSuministroScreen({super.key});

  @override
  State<AddSuministroScreen> createState() => _AddSuministroScreenState();
}

class _AddSuministroScreenState extends State<AddSuministroScreen> {
  final _formKey = GlobalKey<FormState>();
  String _tipo = 'Electricidad';
  final _ciaCtrl = TextEditingController();
  final _contratoCtrl = TextEditingController();
  final _costeCtrl = TextEditingController();

  @override
  void dispose() {
    _ciaCtrl.dispose(); _contratoCtrl.dispose(); _costeCtrl.dispose(); super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, Suministro(
        tipo: _tipo,
        compania: _ciaCtrl.text,
        nContrato: _contratoCtrl.text,
        costeMesAnterior: double.tryParse(_costeCtrl.text) ?? 0.0,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Suministro'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo de Servicio', prefixIcon: Icon(Icons.category, color: Colors.blue)),
                items: ['Electricidad', 'Agua', 'Gas', 'Internet', 'Teléfono', 'Seguridad'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _tipo = v!),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _ciaCtrl,
                decoration: const InputDecoration(labelText: 'Compañía Suministradora', prefixIcon: Icon(Icons.business, color: Colors.blue)),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _contratoCtrl,
                decoration: const InputDecoration(labelText: 'Nº Contrato / Referencia', prefixIcon: Icon(Icons.numbers, color: Colors.blue)),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _costeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Coste Última Factura (€)', prefixIcon: Icon(Icons.euro, color: Colors.blue)),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardar,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: const Text('Guardar Contrato'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
