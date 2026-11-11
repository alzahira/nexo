import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/salud/tratamiento.dart'; // <--- IMPORTANTE: Tu clase Tratamiento

class AddTratamientoScreen extends StatefulWidget {
  // CAMBIO: Ahora recibimos un objeto Tratamiento, no un Map
  final Tratamiento? tratamientoParaEditar;
  const AddTratamientoScreen({super.key, this.tratamientoParaEditar});

  @override
  State<AddTratamientoScreen> createState() => _AddTratamientoScreenState();
}

class _AddTratamientoScreenState extends State<AddTratamientoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medCtrl = TextEditingController();
  final _dosisCtrl = TextEditingController();
  final _frecuenciaCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  
  DateTime _fechaFin = DateTime.now().add(const Duration(days: 7));
  DateTime _fechaInicio = DateTime.now(); // Guardamos la fecha de inicio

  @override
  void initState() {
    super.initState();
    // Si venimos a editar, usamos los PUNTOS (.) para acceder a las propiedades
    if (widget.tratamientoParaEditar != null) {
      final t = widget.tratamientoParaEditar!;
      _medCtrl.text = t.medicamento;
      _dosisCtrl.text = t.dosis;
      _frecuenciaCtrl.text = t.frecuencia.toString();
      _fechaFin = t.fechaFin ?? DateTime.now().add(const Duration(days: 7));
      _fechaInicio = t.fechaInicio;
      // Si tu clase tiene observaciones, cámbialo aquí. 
      // Si en la clase se llama 'notas', usa t.notas
      _obsCtrl.text = t.observaciones; 
    }
  }

  @override
  Widget build(BuildContext context) {
    bool esEdicion = widget.tratamientoParaEditar != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Tratamiento' : 'Nuevo Tratamiento'),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildInput(_medCtrl, 'Medicamento', Icons.medication, obligatorio: true),
            _buildInput(_dosisCtrl, 'Dosis (ej: 1 pastilla)', Icons.science),
            _buildInput(_frecuenciaCtrl, 'Frecuencia (cada X horas)', Icons.timer, isNumber: true),
            
            const SizedBox(height: 10),
            ListTile(
              tileColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Fecha Finalización'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_fechaFin)),
              trailing: const Icon(Icons.calendar_month, color: Colors.orange),
              onTap: _seleccionarFecha,
            ),
            
            const SizedBox(height: 20),
            _buildInput(_obsCtrl, 'Observaciones / Notas', Icons.note, maxLines: 3),
            
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade800,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _guardar,
              child: Text(
                esEdicion ? 'Actualizar' : 'Guardar Tratamiento',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false, int maxLines = 1, bool obligatorio = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (obligatorio && (value == null || value.isEmpty)) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaFin,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2035),
    );
    if (date != null) setState(() => _fechaFin = date);
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      // --- CAMBIO CLAVE: DEVOLVEMOS UN OBJETO TRATAMIENTO ---
      final tratamiento = Tratamiento(
        medicamento: _medCtrl.text,
        dosis: _dosisCtrl.text,
        frecuencia: _frecuenciaCtrl.text.isEmpty ? '8' : _frecuenciaCtrl.text,
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
        observaciones: _obsCtrl.text, // Asegúrate de que tu clase tenga este campo
      );

      Navigator.pop(context, tratamiento); 
    }
  }
}