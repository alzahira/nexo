import 'package:flutter/material.dart';
import '../../models/educacion/evento_escolar.dart';
import 'package:intl/intl.dart';

class AddEventoScreen extends StatefulWidget {
  final EventoEscolar? eventoExistente;
  const AddEventoScreen({super.key, this.eventoExistente});

  @override
  State<AddEventoScreen> createState() => _AddEventoScreenState();
}

class _AddEventoScreenState extends State<AddEventoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tipoCtrl;
  late DateTime _fecha;
  bool _necesitaAuto = false;

  @override
  void initState() {
    super.initState();
    final ev = widget.eventoExistente;
    _tipoCtrl = TextEditingController(text: ev?.tipo ?? '');
    _fecha = ev?.fecha ?? DateTime.now().add(const Duration(days: 5));
    _necesitaAuto = ev?.necesitaAutorizacion ?? false;
  }

  @override
  void dispose() {
    _tipoCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? dt = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (dt != null && context.mounted) {
      setState(() { _fecha = dt; });
    }
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, EventoEscolar(
        tipo: _tipoCtrl.text,
        fecha: _fecha,
        necesitaAutorizacion: _necesitaAuto,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Evento'), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tipoCtrl,
                decoration: InputDecoration(
                  labelText: 'Tipo de Evento (Excursión, Tutoría...)',
                  prefixIcon: const Icon(Icons.festival, color: Colors.deepPurple),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => val!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: () => _seleccionarFecha(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha',
                    prefixIcon: const Icon(Icons.calendar_month, color: Colors.deepPurple),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy').format(_fecha), style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 15),
              SwitchListTile(
                title: const Text('¿Requiere autorización firmada?'),
                value: _necesitaAuto,
                activeThumbColor: Colors.blue,
                onChanged: (v) => setState(() => _necesitaAuto = v),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar Evento'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
                onPressed: _guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
