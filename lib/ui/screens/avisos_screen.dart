import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/usuario_provider.dart';
import '../../models/usuarios/persona.dart';
import '../../models/salud/aviso_salud.dart';
import 'add_aviso_screen.dart';

class AvisosScreen extends StatefulWidget {
  final Persona persona;
  const AvisosScreen({super.key, required this.persona});

  @override
  State<AvisosScreen> createState() => _AvisosScreenState();
}

class _AvisosScreenState extends State<AvisosScreen> {
  @override
  Widget build(BuildContext context) {
    // Control de seguridad: si la lista es nula, usamos una vacía
    final avisos = widget.persona.avisos;

    return Scaffold(
      appBar: AppBar(
        title: Text('Avisos: ${widget.persona.nombre}'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: avisos.isEmpty
          ? const Center(child: Text('No hay avisos pendientes'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: avisos.length,
              itemBuilder: (context, index) => _buildAvisoCard(avisos[index], index),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add_alert, color: Colors.white),
        onPressed: () => _navegarFormulario(),
      ),
    );
  }

  Widget _buildAvisoCard(AvisoSalud aviso, int index) {
    Color colorPrioridad = aviso.prioridad == 'Alta' ? Colors.red : Colors.orange;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: colorPrioridad.withValues(alpha: 0.3))),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: FaIcon(FontAwesomeIcons.bell, color: colorPrioridad),
        title: Text(aviso.titulo.isEmpty ? 'Sin título' : aviso.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Fecha: ${DateFormat('dd/MM/yyyy').format(aviso.fechaAviso)}\n${aviso.descripcion}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blueGrey), onPressed: () => _navegarFormulario(a: aviso, index: index)),
            IconButton(icon: const Icon(Icons.delete_sweep, color: Colors.redAccent), onPressed: () => _confirmarBorrado(index)),
          ],
        ),
      ),
    );
  }

  Future<void> _navegarFormulario({AvisoSalud? a, int? index}) async {
    final resultado = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddAvisoScreen(avisoParaEditar: a)));
    if (resultado != null) {
      if (!mounted) return;
      setState(() {
        if (index != null) {
          widget.persona.avisos[index] = resultado;
        } else {
          widget.persona.avisos.add(resultado);
        }
      });
      context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona);
    }
  }

  void _confirmarBorrado(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar aviso?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(onPressed: () {
            setState(() => widget.persona.avisos.removeAt(index));
            context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona);
            Navigator.pop(context);
          }, child: const Text('BORRAR')),
        ],
      ),
    );
  }
}