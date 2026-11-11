import 'package:flutter/material.dart';
import '../../models/usuarios/persona.dart';
import '../../models/educacion/evento_escolar.dart';
import '../../providers/usuario_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'add_evento_screen.dart';

class EventosScreen extends StatefulWidget {
  final Persona persona;
  const EventosScreen({super.key, required this.persona});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  void _add() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEventoScreen()));
    if (result is EventoEscolar && context.mounted) {
      setState(() {
        widget.persona.rolEstudiante?.eventos.add(result);
        widget.persona.rolEstudiante?.eventos.sort((a,b) => a.fecha.compareTo(b.fecha));
        context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona);
      });
    }
  }

  void _borrar(EventoEscolar ev) {
    setState(() {
      widget.persona.rolEstudiante?.eventos.remove(ev);
      context.read<UsuarioProvider>().notify();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventos = widget.persona.rolEstudiante?.eventos ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos Escolares'), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
      body: eventos.isEmpty 
          ? const Center(child: Text('No hay eventos programados', style: TextStyle(color: Colors.grey, fontSize: 16))) 
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: eventos.length,
              itemBuilder: (c, i) {
                final ev = eventos[i];
                return Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.event_available, color: Colors.deepPurple, size: 30),
                    title: Text(ev.tipo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha: ${DateFormat('dd/MM/yyyy').format(ev.fecha)}'),
                        if (ev.necesitaAutorizacion) 
                           const Text('⚠️ Requiere autorización firmada', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12))
                      ]
                    ),
                    trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.grey), onPressed: () => _borrar(ev)),
                  ),
                );
              }
            ),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, onPressed: _add, child: const Icon(Icons.add)),
    );
  }
}
