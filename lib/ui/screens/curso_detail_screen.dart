import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/usuarios/persona.dart';
import '../../models/educacion/curso_academico.dart';
import 'examenes_screen.dart';
import 'tareas_screen.dart';
import 'calificaciones_screen.dart';

class CursoDetailScreen extends StatelessWidget {
  final CursoAcademico curso;
  final Persona persona;
  
  const CursoDetailScreen({super.key, required this.curso, required this.persona});

  Widget _buildCard(BuildContext context, String titulo, IconData icono, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(curso.nombreCurso), backgroundColor: Colors.orange, foregroundColor: Colors.white),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children: [
          _buildCard(context, 'Mis Exámenes', FontAwesomeIcons.fileSignature, Colors.redAccent, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ExamenesScreen(curso: curso, persona: persona)));
          }),
          _buildCard(context, 'Mis Tareas', FontAwesomeIcons.listCheck, Colors.indigo, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => TareasScreen(curso: curso, persona: persona)));
          }),
          _buildCard(context, 'Boletín Final', FontAwesomeIcons.award, Colors.green, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CalificacionesScreen(curso: curso, persona: persona)));
          }),
        ],
      )
    );
  }
}
