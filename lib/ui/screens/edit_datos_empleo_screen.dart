import 'package:flutter/material.dart';
import '../../models/usuarios/persona.dart';
import '../../models/trabajo/empleado.dart';
import '../../providers/usuario_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EditDatosEmpleoScreen extends StatefulWidget {
  final Persona persona;
  const EditDatosEmpleoScreen({super.key, required this.persona});

  @override
  State<EditDatosEmpleoScreen> createState() => _EditDatosEmpleoScreenState();
}

class _EditDatosEmpleoScreenState extends State<EditDatosEmpleoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _empresaCtrl, _puestoCtrl, _nssCtrl;
  DateTime _fechaIngreso = DateTime.now();

  @override
  void initState() {
    super.initState();
    final emp = widget.persona.rolEmpleado;
    _empresaCtrl = TextEditingController(text: emp?.empresaActual ?? '');
    _puestoCtrl = TextEditingController(text: emp?.puesto ?? '');
    _nssCtrl = TextEditingController(text: emp?.numSeguridadSocial ?? '');
    if (emp != null) _fechaIngreso = emp.fechaIngreso;
  }

  @override
  void dispose() {
    _empresaCtrl.dispose(); _puestoCtrl.dispose(); _nssCtrl.dispose();
    super.dispose();
  }

  void _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaIngreso,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blueGrey),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaIngreso) {
      setState(() {
        _fechaIngreso = picked;
      });
    }
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final emp = widget.persona.rolEmpleado;
      if (emp == null) {
        widget.persona.rolEmpleado = Empleado(
          empresaActual: _empresaCtrl.text,
          puesto: _puestoCtrl.text,
          numSeguridadSocial: _nssCtrl.text,
          fechaIngreso: _fechaIngreso,
        );
      } else {
        emp.empresaActual = _empresaCtrl.text;
        emp.puesto = _puestoCtrl.text;
        emp.numSeguridadSocial = _nssCtrl.text;
        emp.fechaIngreso = _fechaIngreso;
      }
      context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datos Laborales'), backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _empresaCtrl, decoration: const InputDecoration(labelText: 'Empresa Actual', prefixIcon: Icon(Icons.business)), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 15),
              TextFormField(controller: _puestoCtrl, decoration: const InputDecoration(labelText: 'Puesto o Cargo', prefixIcon: Icon(Icons.badge))),
              const SizedBox(height: 15),
              TextFormField(controller: _nssCtrl, decoration: const InputDecoration(labelText: 'Nº Seguridad Social', prefixIcon: Icon(Icons.security))),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: Colors.blueGrey),
                title: const Text('Fecha de Ingreso'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_fechaIngreso)),
                trailing: TextButton(onPressed: () => _seleccionarFecha(context), style: TextButton.styleFrom(foregroundColor: Colors.blueGrey), child: const Text('Cambiar')),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save), 
                label: const Text('Guardar Datos'), 
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
