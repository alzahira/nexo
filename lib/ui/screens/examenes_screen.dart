import 'package:flutter/material.dart';
import '../../models/usuarios/persona.dart';
import '../../models/educacion/examen.dart';
import '../../models/educacion/curso_academico.dart';
import '../../providers/usuario_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'add_examen_screen.dart';

class ExamenesScreen extends StatefulWidget {
  final CursoAcademico curso;
  final Persona persona;
  const ExamenesScreen({super.key, required this.curso, required this.persona});

  @override
  State<ExamenesScreen> createState() => _ExamenesScreenState();
}

class _ExamenesScreenState extends State<ExamenesScreen> {

  void _irAAddExamen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExamenScreen()),
    );
    if (result != null && result is Examen) {
      setState(() {
        widget.curso.examenes.add(result);
        widget.curso.examenes.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
        context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona);
      });
    }
  }

  void _borrarExamen(Examen examen) {
    setState(() {
      widget.curso.examenes.remove(examen);
      context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona);
    });
  }

  @override
  Widget build(BuildContext context) {
    final examenes = widget.curso.examenes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exámenes'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: examenes.isEmpty
          ? const Center(child: Text('No hay exámenes programados', style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: examenes.length,
              itemBuilder: (context, index) {
                final ex = examenes[index];
                final falta = ex.fechaHora.difference(DateTime.now()).inDays;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: ex.nota != null ? Colors.green.shade100 : Colors.red.shade100,
                      radius: 25,
                      child: Text(
                        ex.nota != null ? ex.nota.toString() : (falta < 0 ? 'Fin' : '${falta}d'),
                        style: TextStyle(
                          color: ex.nota != null ? Colors.green.shade800 : Colors.red.shade800, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    title: Text(ex.materia, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(DateFormat('dd/MM/yyyy HH:mm').format(ex.fechaHora)),
                          ],
                        ),
                        if (ex.temario.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text('Temario: ${ex.temario}', style: const TextStyle(fontStyle: FontStyle.italic)),
                        ]
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () => _borrarExamen(ex),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        onPressed: _irAAddExamen,
        icon: const Icon(Icons.add),
        label: const Text('Añadir Examen'),
      ),
    );
  }
}
