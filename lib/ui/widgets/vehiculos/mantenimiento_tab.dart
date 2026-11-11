import 'package:flutter/material.dart';
import '../../../models/vehiculos/vehiculo.dart';
import '../../../models/vehiculos/mantenimiento.dart';

class MantenimientoTab extends StatefulWidget {
  final Vehiculo vehiculo;
  final VoidCallback onChanged;

  const MantenimientoTab({super.key, required this.vehiculo, required this.onChanged});

  @override
  State<MantenimientoTab> createState() => _MantenimientoTabState();
}

class _MantenimientoTabState extends State<MantenimientoTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.vehiculo.historialTaller.isEmpty
          ? const Center(child: Text('No hay registros de taller.'))
          : ListView.builder(
              itemCount: widget.vehiculo.historialTaller.length,
              itemBuilder: (context, index) {
                final mant = widget.vehiculo.historialTaller[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.build_circle,
                      color: Colors.orange,
                      size: 36,
                    ),
                    title: Text(
                      mant.descripcion,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${mant.taller} • ${mant.kilometrajeEnEseMomento} km\nFecha: ${mant.fecha.day}/${mant.fecha.month}/${mant.fecha.year} • Importe: ${mant.importe} €',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'editar') {
                          _mostrarDialogoMantenimiento(
                            context,
                            mantAEditar: mant,
                            index: index,
                          );
                        } else if (value == 'borrar') {
                          _borrarMantenimiento(index);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'editar',
                          child: Text('Editar'),
                        ),
                        const PopupMenuItem(
                          value: 'borrar',
                          child: Text(
                            'Borrar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogoMantenimiento(context),
        icon: const Icon(Icons.add),
        label: const Text('Añadir Revisión'),
      ),
    );
  }

  void _mostrarDialogoMantenimiento(
    BuildContext context, {
    Mantenimiento? mantAEditar,
    int? index,
  }) {
    final esEdicion = mantAEditar != null;

    final tallerCtrl = TextEditingController(text: mantAEditar?.taller ?? '');
    final descCtrl = TextEditingController(
      text: mantAEditar?.descripcion ?? '',
    );
    final importeCtrl = TextEditingController(
      text: mantAEditar?.importe.toString() ?? '',
    );
    final kmCtrl = TextEditingController(
      text:
          mantAEditar?.kilometrajeEnEseMomento.toString() ??
          widget.vehiculo.kilometrosActuales.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            esEdicion ? 'Editar Revisión' : 'Nuevo paso por el Taller',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (ej. Aceite)',
                  ),
                ),
                TextField(
                  controller: tallerCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Taller',
                  ),
                ),
                TextField(
                  controller: kmCtrl,
                  decoration: const InputDecoration(labelText: 'Kilómetros'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: importeCtrl,
                  decoration: const InputDecoration(labelText: 'Importe (€)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final mantGuardado = Mantenimiento(
                  fecha: esEdicion ? mantAEditar.fecha : DateTime.now(),
                  kilometrajeEnEseMomento:
                      int.tryParse(kmCtrl.text) ??
                      widget.vehiculo.kilometrosActuales,
                  taller: tallerCtrl.text,
                  descripcion: descCtrl.text,
                  importe: double.tryParse(importeCtrl.text) ?? 0.0,
                );

                setState(() {
                  final nuevaLista = List<Mantenimiento>.from(
                    widget.vehiculo.historialTaller,
                  );

                  if (esEdicion) {
                    nuevaLista[index!] = mantGuardado;
                  } else {
                    nuevaLista.add(mantGuardado);
                  }

                  widget.vehiculo.historialTaller = nuevaLista;

                  if (mantGuardado.kilometrajeEnEseMomento >
                      widget.vehiculo.kilometrosActuales) {
                    widget.vehiculo.kilometrosActuales =
                        mantGuardado.kilometrajeEnEseMomento;
                  }
                });
                widget.onChanged();
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _borrarMantenimiento(int index) {
    setState(() {
      final nuevaLista = List<Mantenimiento>.from(
        widget.vehiculo.historialTaller,
      );
      nuevaLista.removeAt(index);
      widget.vehiculo.historialTaller = nuevaLista;
    });
    widget.onChanged();
  }
}
