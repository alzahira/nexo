import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/usuario_provider.dart';
import '../../models/usuarios/persona.dart';
import '../../models/salud/tratamiento.dart'; // Asegúrate de que la ruta sea correcta
import 'add_tratamiento_screen.dart';

class TratamientosScreen extends StatefulWidget {
  final Persona persona;
  const TratamientosScreen({super.key, required this.persona});

  @override
  State<TratamientosScreen> createState() => _TratamientosScreenState();
}

class _TratamientosScreenState extends State<TratamientosScreen> {
  // --- SEGURIDAD: Ya no hay lista local 'tratamientos = [...]' ---
  // Ahora todo lee y escribe en widget.persona.tratamientos

  @override
  Widget build(BuildContext context) {
    // Referencia directa a la lista de la persona para que el código sea legible
    final listaTratamientos = widget.persona.tratamientos;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tratamientos: ${widget.persona.nombre}'),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: listaTratamientos.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listaTratamientos.length,
              itemBuilder: (context, index) {
                return _buildTratamientoCard(listaTratamientos[index], index);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade800,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _navegarFormulario(),
      ),
    );
  }

  // --- CARD DE TRATAMIENTO BLINDADA ---
  Widget _buildTratamientoCard(Tratamiento tr, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: FaIcon(
          FontAwesomeIcons.pills, 
          color: Colors.orange.shade700, 
          size: 28
        ),
        title: Text(
          // Blindaje contra campos vacíos
          tr.medicamento.isEmpty ? 'Medicamento no indicado' : tr.medicamento,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${tr.dosis} cada ${tr.frecuencia} horas'),
            const SizedBox(height: 2),
            Text(
              // Si la fecha de fin es null, indicamos que es crónico o indefinido
              tr.fechaFin != null
                  ? 'Finaliza: ${DateFormat('dd/MM/yyyy').format(tr.fechaFin!)}'
                  : 'Tratamiento de larga duración',
              style: const TextStyle(
                fontSize: 12, 
                color: Colors.blueGrey, 
                fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey),
              onPressed: () => _navegarFormulario(tratamiento: tr, index: index),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
              onPressed: () => _confirmarBorrado(index),
            ),
          ],
        ),
      ),
    );
  }

  // --- LÓGICA DE NAVEGACIÓN Y PERSISTENCIA ---
  Future<void> _navegarFormulario({Tratamiento? tratamiento, int? index}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTratamientoScreen(tratamientoParaEditar: tratamiento),
      ),
    );

    // Solo actualizamos si el formulario devuelve un objeto Tratamiento válido
    if (resultado != null && resultado is Tratamiento) {
      if (!mounted) return;
      final prov = context.read<UsuarioProvider>();
      setState(() {
        if (index != null) {
          // Editamos el existente
          widget.persona.tratamientos[index] = resultado;
        } else {
          // Añadimos uno nuevo a la lista de la persona
          widget.persona.tratamientos.add(resultado);
        }
      });
      prov.notify(personaParaGuardar: widget.persona);
    }
  }

  // --- DIÁLOGO DE BORRADO ---
  void _confirmarBorrado(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar tratamiento?'),
        content: const Text('Se eliminará la información de esta medicación.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('CANCELAR')
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final prov = context.read<UsuarioProvider>();
              setState(() {
                widget.persona.tratamientos.removeAt(index);
              });
              prov.notify(personaParaGuardar: widget.persona);
              Navigator.pop(context);
            },
            child: const Text('BORRAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- ESTADO VACÍO ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          const Text(
            'No hay tratamientos registrados', 
            style: TextStyle(color: Colors.grey, fontSize: 16)
          ),
        ],
      ),
    );
  }
}