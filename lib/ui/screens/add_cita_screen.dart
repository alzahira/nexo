import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/salud/cita_medica.dart'; // Importante para usar la clase
import '../theme/app_theme.dart';

class AddCitaScreen extends StatefulWidget {
  final CitaMedica? citaParaEditar; // <--- Cambiado de Map a CitaMedica
  const AddCitaScreen({super.key, this.citaParaEditar});

  @override
  State<AddCitaScreen> createState() => _AddCitaScreenState();
}

class _AddCitaScreenState extends State<AddCitaScreen> {
  final _formKey = GlobalKey<FormState>(); // Para el blindaje/validación
  final _especialidadCtrl = TextEditingController();
  final _doctorCtrl = TextEditingController();
  final _centroCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  DateTime _fechaSeleccionada = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.citaParaEditar != null) {
      _especialidadCtrl.text = widget.citaParaEditar!.especialidad;
      _doctorCtrl.text = widget.citaParaEditar!.doctor;
      _centroCtrl.text = widget.citaParaEditar!.centro;
      _notasCtrl.text = widget.citaParaEditar!.notas ?? '';
      _fechaSeleccionada = widget.citaParaEditar!.fecha;
    }
  }

  // --- ESTA ES LA FUNCIÓN QUE BUSCABAS ---
  void _guardar() {
    // Primero comprobamos que el formulario sea válido (blindaje)
    if (_formKey.currentState!.validate()) {
      
      // Creamos el objeto CitaMedica real
      final nuevaCita = CitaMedica(
        especialidad: _especialidadCtrl.text,
        doctor: _doctorCtrl.text,
        centro: _centroCtrl.text,
        fecha: _fechaSeleccionada,
        notas: _notasCtrl.text,
      );

      // Lo devolvemos a la pantalla anterior
      Navigator.pop(context, nuevaCita); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.citaParaEditar == null ? 'Nueva Cita' : 'Editar Cita')),
      body: Form( // Añadimos Form para la validación
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildTextField(_especialidadCtrl, 'Especialidad', Icons.health_and_safety, obligatorio: true),
            _buildTextField(_doctorCtrl, 'Nombre del Doctor', Icons.person, obligatorio: true),
            _buildTextField(_centroCtrl, 'Centro Médico', Icons.location_on),
            
            const SizedBox(height: 10),
            ListTile(
              tileColor: AppTheme.softSand,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: const Icon(Icons.event, color: Colors.blue),
              title: const Text('Fecha y Hora'),
              subtitle: Text(DateFormat('dd/MM/yyyy - HH:mm').format(_fechaSeleccionada)),
              onTap: _seleccionarFecha,
            ),
            
            const SizedBox(height: 20),
            _buildTextField(_notasCtrl, 'Notas / Preparación', Icons.note, maxLines: 3),
            
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue.shade700,
              ),
              onPressed: _guardar, // <--- Ahora llamamos a la función
              child: const Text('Guardar Cita', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar mejorado con validación
  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1, bool obligatorio = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField( // Cambiado a TextFormField
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        // Blindaje: si es obligatorio y está vacío, avisa al usuario
        validator: (value) {
          if (obligatorio && (value == null || value.isEmpty)) {
            return 'Por favor, rellena este campo';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // Permitir fechas pasadas si editamos
      lastDate: DateTime(2030),
    );
    if (date != null) {
      if (!mounted) return; // Añadir check de mounted
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_fechaSeleccionada),
      );
      if (time != null) {
        if (!mounted) return; // Añadir check de mounted
        setState(() {
          _fechaSeleccionada = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }
}