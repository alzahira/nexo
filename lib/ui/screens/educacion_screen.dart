import 'package:app_home/ui/screens/edit_datos_educacion_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/usuarios/persona.dart';
import 'cursos_screen.dart';
import 'eventos_screen.dart';
import 'pagos_educacion_screen.dart';
import 'titulos_screen.dart';

class EducacionScreen extends StatefulWidget {
  final Persona persona;
  const EducacionScreen({super.key, required this.persona});

  @override
  State<EducacionScreen> createState() => _EducacionScreenState();
}

class _EducacionScreenState extends State<EducacionScreen> {
  void _irAConfigurarEducacion() async {
    final actualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDatosEducacionScreen(persona: widget.persona),
      ),
    );
    if (actualizado == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.persona.rolEstudiante == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Educación: ${widget.persona.nombre}'),
          backgroundColor: Colors.orange.shade700,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.school, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 20),
                Text(
                  '${widget.persona.nombre} no tiene un perfil académico configurado.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Dar de Alta como Alumno'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white),
                  onPressed: _irAConfigurarEducacion,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final alumno = widget.persona.rolEstudiante!;
    return Scaffold(
      appBar: AppBar(
        title: Text('Educación: ${widget.persona.nombre}'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildResumenAlumno(alumno),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _cardEducacion(context, 'Cursos Académicos', FontAwesomeIcons.schoolFlag, Colors.orange, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CursosScreen(persona: widget.persona)));
                }),
                _cardEducacion(context, 'Eventos', FontAwesomeIcons.calendarDay, Colors.deepPurple, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EventosScreen(persona: widget.persona)));
                }),
                _cardEducacion(context, 'Pagos Esc.', FontAwesomeIcons.moneyCheckDollar, Colors.teal, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PagosEducacionScreen(persona: widget.persona)));
                }),
                _cardEducacion(context, 'Títulos', FontAwesomeIcons.graduationCap, Colors.blueGrey, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TitulosScreen(persona: widget.persona)));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenAlumno(dynamic alumno) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('DATOS DEL CENTRO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                onPressed: _irAConfigurarEducacion,
              ),
            ],
          ),
          const Divider(),
          _filaResumen(FontAwesomeIcons.school, 'Centro:', alumno.centroEducativo, Colors.blueGrey),
          _filaResumen(FontAwesomeIcons.stairs, 'Curso:', alumno.curso, Colors.teal),
          _filaResumen(FontAwesomeIcons.userGraduate, 'Tutor:', alumno.tutor, Colors.blue),
        ],
      ),
    );
  }

  Widget _filaResumen(IconData icono, String etiqueta, String valor, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          FaIcon(icono, color: color, size: 16),
          const SizedBox(width: 10),
          Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(valor.isEmpty ? 'No especificado' : valor, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _cardEducacion(BuildContext context, String titulo, IconData icono, Color color, VoidCallback onTap) {
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