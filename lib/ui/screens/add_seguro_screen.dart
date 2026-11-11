import 'package:flutter/material.dart';
import '../../models/hogar/seguro_hogar.dart';
import 'package:intl/intl.dart';

class AddSeguroScreen extends StatefulWidget {
  final SeguroHogar? seguroExistente;
  const AddSeguroScreen({super.key, this.seguroExistente});

  @override
  State<AddSeguroScreen> createState() => _AddSeguroScreenState();
}

class _AddSeguroScreenState extends State<AddSeguroScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companiaCtrl;
  late TextEditingController _nPolizaCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _primaCtrl;
  DateTime _fechaVencimiento = DateTime.now().add(const Duration(days: 365));

  @override
  void initState() {
    super.initState();
    _companiaCtrl = TextEditingController(text: widget.seguroExistente?.compania);
    _nPolizaCtrl = TextEditingController(text: widget.seguroExistente?.nPoliza);
    _telefonoCtrl = TextEditingController(text: widget.seguroExistente?.telefonoAsistencia);
    _primaCtrl = TextEditingController(text: widget.seguroExistente?.primaAnual.toString());
    if (widget.seguroExistente != null) {
      _fechaVencimiento = widget.seguroExistente!.fechaVencimiento;
    }
  }

  @override
  void dispose() {
    _companiaCtrl.dispose(); _nPolizaCtrl.dispose(); _telefonoCtrl.dispose(); _primaCtrl.dispose();
    super.dispose();
  }

  void _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _fechaVencimiento = picked);
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, SeguroHogar(
        compania: _companiaCtrl.text,
        nPoliza: _nPolizaCtrl.text,
        telefonoAsistencia: _telefonoCtrl.text,
        primaAnual: double.tryParse(_primaCtrl.text) ?? 0.0,
        fechaVencimiento: _fechaVencimiento,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.seguroExistente == null ? 'Registrar Seguro' : 'Editar Seguro'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _companiaCtrl, decoration: const InputDecoration(labelText: 'Compañía Aseguradora', prefixIcon: Icon(Icons.business)), validator: (v) => v!.isEmpty ? 'Obligatorio' : null),
              const SizedBox(height: 15),
              TextFormField(controller: _nPolizaCtrl, decoration: const InputDecoration(labelText: 'Número de Póliza', prefixIcon: Icon(Icons.numbers)), validator: (v) => v!.isEmpty ? 'Obligatorio' : null),
              const SizedBox(height: 15),
              TextFormField(controller: _telefonoCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Teléfono de Asistencia 24h', prefixIcon: Icon(Icons.phone)), validator: (v) => v!.isEmpty ? 'Obligatorio' : null),
              const SizedBox(height: 15),
              TextFormField(controller: _primaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prima Anual (€)', prefixIcon: Icon(Icons.euro)), validator: (v) => v!.isEmpty ? 'Obligatorio' : null),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: Colors.redAccent),
                title: const Text('Fecha de Vencimiento'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_fechaVencimiento)),
                trailing: TextButton(onPressed: _seleccionarFecha, child: const Text('Cambiar', style: TextStyle(color: Colors.redAccent))),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save), 
                label: const Text('Guardar Seguro'), 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)), 
                onPressed: _guardar
              )
            ]
          )
        )
      )
    );
  }
}
