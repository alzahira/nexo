import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/usuarios/persona.dart';
import '../../models/educacion/curso_academico.dart';
import '../../providers/usuario_provider.dart';
import 'add_curso_screen.dart';
import 'curso_detail_screen.dart';

class CursosScreen extends StatefulWidget {
  final Persona persona;
  const CursosScreen({super.key, required this.persona});

  @override
  State<CursosScreen> createState() => _CursosScreenState();
}

class _CursosScreenState extends State<CursosScreen> {
  void _add() async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCursoScreen()));
    if (res is CursoAcademico && context.mounted) {
      setState(() {
        if (widget.persona.rolEstudiante != null) {
          widget.persona.rolEstudiante!.historialAcademico.add(res);
          context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cursos = widget.persona.rolEstudiante?.historialAcademico ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Historial Académico'), backgroundColor: Colors.orange, foregroundColor: Colors.white),
      body: cursos.isEmpty 
        ? const Center(child: Text('Añade tu curso actual para comenzar (+)', style: TextStyle(color: Colors.grey, fontSize: 16)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cursos.length,
            itemBuilder: (c, i) {
              final curso = cursos[i];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: const Icon(Icons.menu_book, color: Colors.orange, size: 40),
                  title: Text(curso.nombreCurso, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text('${curso.nivel}\nCentro: ${curso.centro}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Al tocar se abre el menú de Opciones de ESE curso en concreto
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => CursoDetailScreen(curso: curso, persona: widget.persona)
                    ));
                  },
                ),
              );
            }
          ),
      floatingActionButton: FloatingActionButton.extended(backgroundColor: Colors.orange, foregroundColor: Colors.white, onPressed: _add, icon: const Icon(Icons.add), label: const Text('Nuevo Curso')),
    );
  }
}
