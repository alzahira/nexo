import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/usuarios/persona.dart';
import '../../models/educacion/calificacion_materia.dart';
import '../../models/educacion/curso_academico.dart';
import '../../providers/usuario_provider.dart';
import 'add_calificacion_screen.dart';
import '../theme/app_theme.dart';

class CalificacionesScreen extends StatefulWidget {
  final CursoAcademico curso;
  final Persona persona;
  const CalificacionesScreen({super.key, required this.curso, required this.persona});
  @override
  State<CalificacionesScreen> createState() => _CalificacionesScreenState();
}

class _CalificacionesScreenState extends State<CalificacionesScreen> {

  void _add() async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCalificacionScreen()));
    if (res is CalificacionMateria && context.mounted) {
      setState(() { 
        widget.curso.calificaciones.add(res); 
        context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona); 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notas = widget.curso.calificaciones;
    return Scaffold(
      appBar: AppBar(title: const Text('Boletín de Notas'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20), 
            color: Colors.green.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                Expanded(
                  child: Text(
                    widget.curso.nombreCurso, 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)
                  ),
                ),
                const Icon(Icons.school, color: Colors.green, size: 30)
              ]
            ),
          ),
          Expanded(
            child: notas.isEmpty 
              ? const Center(child: Text('Añade asignaturas y notas (+)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16))) 
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notas.length, 
                  itemBuilder: (c,i) {
                    final n = notas[i];
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.book, color: Colors.green),
                        title: Text(n.asignatura, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        trailing: CircleAvatar(
                          backgroundColor: n.notaFinal >= 5 ? Colors.green.shade100 : Colors.red.shade100, 
                          child: Text(
                            n.notaFinal.toString(), 
                            style: TextStyle(
                              color: n.notaFinal >= 5 ? Colors.green.shade800 : Colors.red.shade800, 
                              fontWeight: FontWeight.bold
                            )
                          )
                        ),
                        onLongPress: () => setState(() { 
                          widget.curso.calificaciones.remove(n); 
          context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona); 
        }),
                      ),
                    );
                  }
                )
            )
        ]
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green, 
        foregroundColor: Colors.white, 
        onPressed: _add, 
        icon: const Icon(Icons.add),
        label: const Text('Añadir Nota')
      ),
    );
  }
}
