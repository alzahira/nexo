import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/usuarios/persona.dart';
import '../../models/educacion/titulo.dart';
import '../../providers/usuario_provider.dart';
import 'add_titulo_screen.dart';

class TitulosScreen extends StatefulWidget {
  final Persona persona;
  const TitulosScreen({super.key, required this.persona});
  @override
  State<TitulosScreen> createState() => _TitulosScreenState();
}

class _TitulosScreenState extends State<TitulosScreen> {
  void _add() async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTituloScreen()));
    if (res is Titulo && context.mounted) {
      setState(() { 
        widget.persona.rolEstudiante?.titulos.add(res); 
        context.read<UsuarioProvider>().notify(); 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tits = widget.persona.rolEstudiante?.titulos ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Diplomas y Títulos'), backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
      body: tits.isEmpty 
          ? const Center(child: Text('Ningún título acreditado', style: TextStyle(color: Colors.grey, fontSize: 16))) 
          : ListView.builder(
              padding: const EdgeInsets.all(16), 
              itemCount: tits.length, 
              itemBuilder: (c,i) {
                final t = tits[i];
                return Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.workspace_premium, color: Colors.amber, size: 40),
                    title: Text(t.nombreTitulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.institucion, style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('Expedido: ${DateFormat('yyyy').format(t.fechaExpedicion)}'),
                        if (t.calificacionHonor.isNotEmpty) 
                          Text(t.calificacionHonor, style: const TextStyle(color: Colors.amber, fontStyle: FontStyle.italic))
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey), 
                      onPressed: () => setState(() { 
                        tits.remove(t); 
                        context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona); 
                      })
                    ),
                  )
                );
              }
            ),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white, onPressed: _add, child: const Icon(Icons.add)),
    );
  }
}
