import 'package:flutter/material.dart';
import '../../models/educacion/titulo.dart';
import 'package:intl/intl.dart';

class AddTituloScreen extends StatefulWidget {
  final Titulo? tituloExistente;
  const AddTituloScreen({super.key, this.tituloExistente});

  @override
  State<AddTituloScreen> createState() => _AddTituloScreenState();
}

class _AddTituloScreenState extends State<AddTituloScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl, _instCtrl, _califCtrl;
  late DateTime _fecha;

  @override
  void initState() {
    super.initState();
    final t = widget.tituloExistente;
    _nombreCtrl = TextEditingController(text: t?.nombreTitulo ?? '');
    _instCtrl = TextEditingController(text: t?.institucion ?? '');
    _califCtrl = TextEditingController(text: t?.calificacionHonor ?? '');
    _fecha = t?.fechaExpedicion ?? DateTime.now();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose(); 
    _instCtrl.dispose(); 
    _califCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? dt = await showDatePicker(
      context: context, 
      initialDate: _fecha, 
      firstDate: DateTime(1980), 
      lastDate: DateTime.now()
    );
    if (dt != null && context.mounted) setState(() => _fecha = dt);
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, Titulo(
        nombreTitulo: _nombreCtrl.text, 
        institucion: _instCtrl.text, 
        fechaExpedicion: _fecha, 
        calificacionHonor: _califCtrl.text
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Título'), backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreCtrl, 
                decoration: InputDecoration(
                  labelText: 'Nombre del Diploma/Título',
                  prefixIcon: const Icon(Icons.workspace_premium, color: Colors.blueGrey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                ), 
                validator: (v) => v!.isEmpty ? 'Requerido' : null
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _instCtrl, 
                decoration: InputDecoration(
                  labelText: 'Institución (Colegio, Universidad)',
                  prefixIcon: const Icon(Icons.account_balance, color: Colors.blueGrey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: () => _seleccionarFecha(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha de Expedición',
                    prefixIcon: const Icon(Icons.calendar_month, color: Colors.blueGrey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: Text(DateFormat('dd/MM/yyyy').format(_fecha))
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _califCtrl, 
                decoration: InputDecoration(
                  labelText: 'Calificación Honorífica (Ej. Cum Laude, Matrícula)',
                  prefixIcon: const Icon(Icons.stars, color: Colors.blueGrey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                )
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)), 
                onPressed: _guardar
              )
            ]
          )
        )
      )
    );
  }
}
