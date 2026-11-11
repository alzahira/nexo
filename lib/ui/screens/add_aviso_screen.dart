import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/salud/aviso_salud.dart';

class AddAvisoScreen extends StatefulWidget {
  final AvisoSalud? avisoParaEditar;
  const AddAvisoScreen({super.key, this.avisoParaEditar});

  @override
  State<AddAvisoScreen> createState() => _AddAvisoScreenState();
}

class _AddAvisoScreenState extends State<AddAvisoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _prioridad = 'Media';
  DateTime _fecha = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.avisoParaEditar != null) {
      final a = widget.avisoParaEditar!;
      _tituloCtrl.text = a.titulo;
      _descCtrl.text = a.descripcion;
      _prioridad = a.prioridad;
      _fecha = a.fechaAviso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.avisoParaEditar == null ? 'Nuevo Aviso' : 'Editar Aviso')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(labelText: 'Título del Aviso', prefixIcon: Icon(Icons.notification_important)),
              validator: (v) => v == null || v.isEmpty ? 'Debes indicar un título' : null,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _prioridad,
              decoration: const InputDecoration(labelText: 'Prioridad', prefixIcon: Icon(Icons.priority_high)),
              items: ['Alta', 'Media', 'Baja'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (val) => setState(() => _prioridad = val!),
            ),
            const SizedBox(height: 20),
            ListTile(
              tileColor: Colors.grey.shade100,
              title: const Text('Fecha Límite'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_fecha)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _fecha, firstDate: DateTime.now(), lastDate: DateTime(2030));
                if (d != null) setState(() => _fecha = d);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descripción / Notas', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context, AvisoSalud(
                    titulo: _tituloCtrl.text,
                    prioridad: _prioridad,
                    fechaAviso: _fecha,
                    descripcion: _descCtrl.text,
                  ));
                }
              },
              child: const Text('Guardar Aviso', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}