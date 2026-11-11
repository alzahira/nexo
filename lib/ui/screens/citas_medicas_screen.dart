import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/usuario_provider.dart';
import '../../models/usuarios/persona.dart';
import '../../models/salud/cita_medica.dart';
import 'add_cita_screen.dart';
import '../theme/app_theme.dart';

class CitasMedicasScreen extends StatefulWidget {
  final Persona persona;
  const CitasMedicasScreen({super.key, required this.persona});

  @override
  State<CitasMedicasScreen> createState() => _CitasMedicasScreenState();
}

class _CitasMedicasScreenState extends State<CitasMedicasScreen> {
  // --- ELIMINADA LA LISTA LOCAL 'citas' ---
  // Ahora usamos siempre widget.persona.citas para que los datos sean persistentes por persona.

  @override
  Widget build(BuildContext context) {
    // Referencia corta a la lista de la persona para limpiar el código
    final listaCitas = widget.persona.citas;

    return Scaffold(
      appBar: AppBar(
        title: Text('Citas de ${widget.persona.nombre}'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: listaCitas.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listaCitas.length,
              itemBuilder: (context, index) {
                return _buildCitaCard(listaCitas[index], index);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final nuevaCita = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCitaScreen()),
          );

          if (!context.mounted) return;

          if (nuevaCita != null) {
            final prov = context.read<UsuarioProvider>();
            setState(() {
              widget.persona.citas.add(nuevaCita);
            });
            // Notificar al provider para que guarde en Firestore y actualice el calendario
            prov.notify(personaParaGuardar: widget.persona);
          }
        },
      ),
    );
  }

  // Cambiamos 'Map' por 'dynamic' o 'CitaMedica' según uses clase o mapa
  Widget _buildCitaCard(CitaMedica cita, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.calendar_today, color: Colors.blue.shade700),
        ),
        // SEGURIDAD: Usamos ?? para evitar nulos y .isEmpty para campos vacíos
        title: Text(
        cita.especialidad.isEmpty ? 'Especialidad no indicada' : cita.especialidad,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
            '${cita.doctor.isEmpty ? 'Dr. no asignado' : cita.doctor} - ${cita.centro.isEmpty ? 'Centro no indicado' : cita.centro}',
          ),
          const SizedBox(height: 5),
            Text(
            DateFormat('dd/MM/yyyy - HH:mm').format(cita.fecha),
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey),
              onPressed: () async {
                final citaEditada = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddCitaScreen(citaParaEditar: cita),
                  ),
                );

                if (!mounted) return;

                if (citaEditada != null) {
                  final prov = context.read<UsuarioProvider>();
                  setState(() {
                    widget.persona.citas[index] = citaEditada;
                  });
                  prov.notify(personaParaGuardar: widget.persona);
                }
              },
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

  void _confirmarBorrado(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar cita?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final prov = context.read<UsuarioProvider>();
              setState(() {
                widget.persona.citas.removeAt(index);
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: AppTheme.accentLight),
          const SizedBox(height: 20),
          const Text(
            'No hay citas para esta persona',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
