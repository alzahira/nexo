import 'package:app_home/ui/screens/avisos_screen.dart';
import 'package:app_home/ui/screens/citas_medicas_screen.dart';
import 'package:app_home/ui/screens/historial_screen.dart';
import 'package:app_home/ui/screens/pruebas_medicas_screen.dart';
import 'package:app_home/ui/screens/tratamientos_screen.dart';
import 'package:app_home/ui/screens/edit_datos_medicos_screen.dart'; // Asegúrate de crear este
import 'package:app_home/ui/screens/vacunas_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/usuarios/persona.dart';

class SaludScreen extends StatefulWidget {
  final Persona persona;
  const SaludScreen({super.key, required this.persona});

  @override
  State<SaludScreen> createState() => _SaludScreenState();
}

class _SaludScreenState extends State<SaludScreen> {
  // Función para ir a editar y refrescar al volver
  void _irAEditarDatosMedicos() async {
    final actualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDatosMedicosScreen(persona: widget.persona),
      ),
    );

    // Si el formulario devolvió 'true', refrescamos la pantalla
    if (actualizado == true) {
      setState(() {}); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salud: ${widget.persona.nombre}'),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Pasamos el context a la función de la cabecera
          _buildResumenPaciente(context),

          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _cardSalud(context, 'Citas Médicas', FontAwesomeIcons.calendarCheck, Colors.blue, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CitasMedicasScreen(persona: widget.persona)));
                }),
                _cardSalud(context, 'Historial', FontAwesomeIcons.fileMedical, Colors.teal, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => HistorialScreen(persona: widget.persona)));
                }),
                _cardSalud(context, 'Tratamientos', FontAwesomeIcons.pills, Colors.orange, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TratamientosScreen(persona: widget.persona)));
                }),
                _cardSalud(context, 'Vacunas', FontAwesomeIcons.syringe, Colors.purple, () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => VacunasScreen(persona: widget.persona)),
  );
}),
                _cardSalud(
  context, 
  'Pruebas', 
  FontAwesomeIcons.microscope, 
  Colors.indigo, 
  () {
    Navigator.push(
      context,
      MaterialPageRoute(
        
        builder: (context) => PruebasScreen(persona: widget.persona), 
      ),
    );
  },
),
                _cardSalud(context, 'Avisos', FontAwesomeIcons.bell, Colors.redAccent, () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => AvisosScreen(persona: widget.persona)),
  );
}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenPaciente(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('DATOS MÉDICOS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.red, size: 20),
                onPressed: _irAEditarDatosMedicos, // Llamamos a la función de arriba
              ),
            ],
          ),
          const Divider(),
          _filaResumen(FontAwesomeIcons.triangleExclamation, 'Alergias:', widget.persona.alergiasConocidas, Colors.red),
          _filaResumen(FontAwesomeIcons.userDoctor, 'Médico:', widget.persona.medicoCabecera, Colors.blueGrey),
          _filaResumen(FontAwesomeIcons.hospital, 'Centro:', widget.persona.centroMedico, Colors.teal),
          _filaResumen(FontAwesomeIcons.idCardClip, 'Seg. Social:', widget.persona.numSeguridadSocial, Colors.blue),
        ],
      ),
    );
  }

  Widget _filaResumen(FaIconData icono, String etiqueta, String valor, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          FaIcon(icono, color: color, size: 16),
          const SizedBox(width: 10),
          Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(valor.isEmpty ? 'No asignado' : valor, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _cardSalud(BuildContext context, String titulo, FaIconData icono, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icono, color: color, size: 40),
            const SizedBox(height: 15),
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}