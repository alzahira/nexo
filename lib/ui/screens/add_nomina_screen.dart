import 'package:flutter/material.dart';
import '../../models/trabajo/nomina.dart';

class AddNominaScreen extends StatefulWidget {
  const AddNominaScreen({super.key});

  @override
  State<AddNominaScreen> createState() => _AddNominaScreenState();
}

class _AddNominaScreenState extends State<AddNominaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _importeCtrl = TextEditingController();
  final _archivoURLCtrl = TextEditingController();
  int _mes = DateTime.now().month;
  int _ano = DateTime.now().year;

  @override
  void dispose() {
    _importeCtrl.dispose();
    _archivoURLCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, Nomina(
        mes: _mes,
        ano: _ano,
        importeLiquido: double.tryParse(_importeCtrl.text) ?? 0.0,
        archivoURL: _archivoURLCtrl.text.isNotEmpty ? _archivoURLCtrl.text : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Nómina'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _mes,
                      decoration: const InputDecoration(labelText: 'Mes', prefixIcon: Icon(Icons.date_range)),
                      items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                      onChanged: (v) => setState(() => _mes = v!),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _ano,
                      decoration: const InputDecoration(labelText: 'Año'),
                      items: List.generate(10, (i) => DropdownMenuItem(value: DateTime.now().year - i, child: Text('${DateTime.now().year - i}'))),
                      onChanged: (v) => setState(() => _ano = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _importeCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Importe Líquido (€)', prefixIcon: Icon(Icons.euro)),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(controller: _archivoURLCtrl, decoration: const InputDecoration(labelText: 'URL Archivo PDF (Opcional)', prefixIcon: Icon(Icons.link))),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save), 
                label: const Text('Guardar Nómina'), 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)), 
                onPressed: _guardar
              )
            ]
          )
        )
      )
    );
  }
}
