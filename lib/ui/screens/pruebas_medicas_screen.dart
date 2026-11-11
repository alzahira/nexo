import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/usuario_provider.dart';
import '../../models/usuarios/persona.dart';
import '../../models/salud/prueba_medica.dart';
import 'add_prueba_screen.dart';

class PruebasScreen extends StatefulWidget {
  final Persona persona;
  const PruebasScreen({super.key, required this.persona});

  @override
  State<PruebasScreen> createState() => _PruebasScreenState();
}

class _PruebasScreenState extends State<PruebasScreen> {
  @override
  Widget build(BuildContext context) {
    final pruebas = widget.persona.pruebasMedicas;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pruebas de ${widget.persona.nombre}'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: pruebas.isEmpty
          ? const Center(
              child: Text(
                'No hay pruebas registradas',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pruebas.length,
              itemBuilder: (context, index) =>
                  _buildPruebaCard(pruebas[index], index),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo.shade700,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _navegarFormulario(),
      ),
    );
  }

  Widget _buildPruebaCard(PruebaMedica p, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        leading: const Icon(Icons.biotech, color: Colors.indigo),
        title: Text(
          p.tipoPrueba,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${p.centro} - ${DateFormat('dd/MM/yyyy').format(p.fecha)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resultado:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(p.resultado.isEmpty ? 'Sin resumen' : p.resultado),
                const SizedBox(height: 15),
                if (p.archivoURL != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(p.archivoURL!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                      onPressed: () => _navegarFormulario(p: p, index: index),
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

  Future<void> _navegarFormulario({PruebaMedica? p, int? index}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPruebaScreen(pruebaParaEditar: p),
      ),
    );

    if (resultado != null) {
      if (!mounted) return;
      final prov = context.read<UsuarioProvider>();
      setState(() {
        if (index != null) {
          widget.persona.pruebasMedicas[index] = resultado;
        } else {
          widget.persona.pruebasMedicas.add(resultado);
        }
      });
      prov.notify(personaParaGuardar: widget.persona);
    }
  }

  void _confirmarBorrado(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar prueba?'),
        content: const Text('Se borrará el registro de esta prueba médica.'),
        actions: [
          TextButton(
            onPressed: () {
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              final prov = context.read<UsuarioProvider>();
              setState(() => widget.persona.pruebasMedicas.removeAt(index));
              prov.notify(personaParaGuardar: widget.persona);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('BORRAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
