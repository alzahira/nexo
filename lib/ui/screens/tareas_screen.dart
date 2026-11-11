import 'package:flutter/material.dart';
import '../../models/usuarios/persona.dart';
import '../../models/educacion/tarea.dart';
import '../../models/educacion/curso_academico.dart';
import '../../providers/usuario_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'add_tarea_screen.dart';
import '../theme/app_theme.dart';

class TareasScreen extends StatefulWidget {
  final CursoAcademico curso;
  final Persona persona;
  const TareasScreen({super.key, required this.curso, required this.persona});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {

  void _irAAddTarea() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTareaScreen()),
    );
    if (result != null && result is Tarea) {
      setState(() {
        widget.curso.tareas.add(result);
        widget.curso.tareas.sort((a, b) => a.fechaEntrega.compareTo(b.fechaEntrega));
        context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona);
      });
    }
  }

  void _borrarTarea(Tarea tarea) {
    setState(() {
      widget.curso.tareas.remove(tarea);
      context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona);
    });
  }

  void _toggleEntrega(Tarea tarea) {
    setState(() {
      tarea.entregado = !tarea.entregado;
      context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tareas = widget.curso.tareas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: tareas.isEmpty
          ? const Center(child: Text('No hay tareas pendientes', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tareas.length,
              itemBuilder: (context, index) {
                final t = tareas[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: Checkbox(
                      value: t.entregado,
                      activeColor: Colors.indigo,
                      onChanged: (val) => _toggleEntrega(t),
                    ),
                    title: Text(
                      t.titulo, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        decoration: t.entregado ? TextDecoration.lineThrough : null,
                        color: t.entregado ? AppTheme.textSecondary : Colors.black,
                      )
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: t.entregado ? AppTheme.textSecondary : Colors.orange),
                            const SizedBox(width: 5),
                            Text(
                              'Entrega: ${DateFormat('dd/MM/yyyy').format(t.fechaEntrega)}',
                              style: TextStyle(color: t.entregado ? AppTheme.textSecondary : Colors.deepOrange),
                            ),
                          ],
                        ),
                        if (t.descripcion.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(t.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ]
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppTheme.textSecondary),
                      onPressed: () => _borrarTarea(t),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: _irAAddTarea,
        icon: const Icon(Icons.add_task),
        label: const Text('Nueva Tarea'),
      ),
    );
  }
}
