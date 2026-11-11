import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/usuario_provider.dart';
import '../../models/usuarios/persona.dart';
import '../../models/salud/visita_historial.dart';
import 'add_historial_screen.dart';
import '../theme/app_theme.dart';

class HistorialScreen extends StatefulWidget {
  final Persona persona;
  const HistorialScreen({super.key, required this.persona});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  @override
  Widget build(BuildContext context) {
    final historial = widget.persona.historial;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial Médico'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: historial.isEmpty
          ? const Center(child: Text('Historial vacío'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historial.length,
              itemBuilder: (context, index) =>
                  _buildHistorialCard(historial[index], index),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal.shade700,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
        onPressed: () => _navegarFormulario(),
      ),
    );
  }

  Widget _buildHistorialCard(VisitaHistorial item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: ExpansionTile(
        leading: const Icon(Icons.history_edu, color: Colors.teal),
        title: Text(
          item.incidencia.isEmpty ? 'Sin incidencia' : item.incidencia,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Text(
          '${item.centroSalud} - ${DateFormat('dd/MM/yyyy').format(item.fecha)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _datoHistorial('Valoración:', item.valoracion),
                const SizedBox(height: 10),
                _datoHistorial(
                  'Tratamiento:',
                  item.tratamientoRecomendado,
                  color: Colors.blue.shade900,
                ),

                if (item.fotoInforme != null) ...[
                  const SizedBox(height: 15),
                  const Text(
                    'Documento adjunto:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(item.fotoInforme!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],

                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                      onPressed: () =>
                          _navegarFormulario(item: item, index: index),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_sweep,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _confirmarBorrado(index),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navegarFormulario({
    VisitaHistorial? item,
    int? index,
  }) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHistorialScreen(itemParaEditar: item),
      ),
    );
    if (resultado != null) {
      if (!mounted) return;
      final prov = context.read<UsuarioProvider>();
      setState(() {
        if (index != null) {
          widget.persona.historial[index] = resultado;
        } else {
          widget.persona.historial.add(resultado);
        }
      });
      prov.notify(personaParaGuardar: widget.persona);
    }
  }

  void _confirmarBorrado(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar registro?'),
        content: const Text('Se borrará este informe del historial.'),
        actions: [
          TextButton(
            onPressed: () {
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () {
              final prov = context.read<UsuarioProvider>();
              setState(() => widget.persona.historial.removeAt(index));
              prov.notify(personaParaGuardar: widget.persona);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('SÍ, BORRAR'),
          ),
        ],
      ),
    );
  }

  Widget _datoHistorial(
    String label,
    String valor, {
    Color color = Colors.black87,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(valor, style: TextStyle(fontSize: 15, color: color)),
      ],
    );
  }
}
