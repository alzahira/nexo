import 'package:flutter/material.dart';
import '../../models/educacion/examen.dart';
import 'package:intl/intl.dart';

class AddExamenScreen extends StatefulWidget {
  final Examen? examenExistente;
  const AddExamenScreen({super.key, this.examenExistente});

  @override
  State<AddExamenScreen> createState() => _AddExamenScreenState();
}

class _AddExamenScreenState extends State<AddExamenScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _materiaCtrl;
  late TextEditingController _temarioCtrl;
  late TextEditingController _notaCtrl;
  late DateTime _fechaHora;

  @override
  void initState() {
    super.initState();
    final e = widget.examenExistente;
    _materiaCtrl = TextEditingController(text: e?.materia ?? '');
    _temarioCtrl = TextEditingController(text: e?.temario ?? '');
    _notaCtrl = TextEditingController(text: e?.nota?.toString() ?? '');
    _fechaHora = e?.fechaHora ?? DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _materiaCtrl.dispose();
    _temarioCtrl.dispose();
    _notaCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFechaHora(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaHora,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (fecha != null && context.mounted) {
      final TimeOfDay? hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_fechaHora),
      );
      if (hora != null) {
        setState(() {
          _fechaHora = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
        });
      }
    }
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final notaParsed = double.tryParse(_notaCtrl.text.replaceAll(',', '.'));
      final nuevoExamen = Examen(
        materia: _materiaCtrl.text,
        fechaHora: _fechaHora,
        temario: _temarioCtrl.text,
        nota: notaParsed,
      );
      Navigator.pop(context, nuevoExamen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examenExistente == null ? 'Añadir Examen' : 'Editar Examen'),
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
              TextFormField(
                controller: _materiaCtrl,
                decoration: InputDecoration(
                  labelText: 'Materia / Asignatura',
                  prefixIcon: const Icon(Icons.menu_book, color: Colors.redAccent),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Introduce la materia' : null,
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: () => _seleccionarFechaHora(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha y Hora del Examen',
                    prefixIcon: const Icon(Icons.calendar_month, color: Colors.redAccent),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy HH:mm').format(_fechaHora), style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _temarioCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Temario / Temas a estudiar',
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.list_alt, color: Colors.redAccent),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _notaCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Nota (Opcional, si ya está calificado)',
                  prefixIcon: const Icon(Icons.grading, color: Colors.redAccent),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar Examen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
