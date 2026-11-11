import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/usuario_provider.dart';
import '../../models/usuarios/persona.dart';
import '../../models/salud/vacuna.dart';
import 'add_vacuna_screen.dart';
import '../theme/app_theme.dart';

class VacunasScreen extends StatefulWidget {
  final Persona persona;
  const VacunasScreen({super.key, required this.persona});

  @override
  State<VacunasScreen> createState() => _VacunasScreenState();
}

class _VacunasScreenState extends State<VacunasScreen> {
  @override
  Widget build(BuildContext context) {
    final vacunas = widget.persona.vacunas;

    return Scaffold(
      appBar: AppBar(
        title: Text('Vacunas de ${widget.persona.nombre}'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: vacunas.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vacunas.length,
              itemBuilder: (context, index) => _buildVacunaCard(vacunas[index], index),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple.shade700,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _navegarFormulario(),
      ),
    );
  }

  Widget _buildVacunaCard(Vacuna v, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        leading: Icon(Icons.shield, color: Colors.purple.shade700),
        title: Text(v.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Dosis: ${v.dosis} - ${DateFormat('dd/MM/yyyy').format(v.fechaPuesta)}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (v.laboratorio.isNotEmpty)
                   Text('Laboratorio/Lote: ${v.laboratorio}'),
                const SizedBox(height: 10),
                if (v.fotoPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(File(v.fotoPath!), height: 150, width: double.infinity, fit: BoxFit.cover),
                  ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                      onPressed: () => _navegarFormulario(v: v, index: index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                      onPressed: () => _confirmarBorrado(index),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _navegarFormulario({Vacuna? v, int? index}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddVacunaScreen(vacunaParaEditar: v)),
    );

    if (resultado != null) {
      if (!mounted) return;
      final prov = context.read<UsuarioProvider>();
      setState(() {
        if (index != null) {
          widget.persona.vacunas[index] = resultado;
        } else {
          widget.persona.vacunas.add(resultado);
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
        content: const Text('Se borrará la información de esta vacuna.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(onPressed: () {
            final prov = context.read<UsuarioProvider>();
            setState(() => widget.persona.vacunas.removeAt(index));
            prov.notify(personaParaGuardar: widget.persona);
            if (context.mounted) {
              Navigator.pop(context);
            }
          }, child: const Text('BORRAR', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('No hay vacunas registradas', style: TextStyle(color: AppTheme.textSecondary)));
  }
}