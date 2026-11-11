import 'package:flutter/material.dart';
import '../../../models/vehiculos/vehiculo.dart';
import '../../../models/vehiculos/multa.dart';

class MultasTab extends StatefulWidget {
  final Vehiculo vehiculo;
  final VoidCallback onChanged;

  const MultasTab({super.key, required this.vehiculo, required this.onChanged});

  @override
  State<MultasTab> createState() => _MultasTabState();
}

class _MultasTabState extends State<MultasTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.vehiculo.multas.isEmpty
          ? const Center(
              child: Text(
                '¡Genial! No hay multas registradas en este vehículo.',
              ),
            )
          : ListView.builder(
              itemCount: widget.vehiculo.multas.length,
              itemBuilder: (context, index) {
                final multa = widget.vehiculo.multas[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: multa.pagada
                          ? Colors.transparent
                          : Colors.red.shade300,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      multa.pagada ? Icons.check_circle : Icons.warning,
                      color: multa.pagada ? Colors.green : Colors.red,
                      size: 36,
                    ),
                    title: Text(
                      multa.motivo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Importe: ${multa.importe} €'
                      '${multa.puntosDetraidos > 0 ? " • Puntos: -${multa.puntosDetraidos}" : ""}\n'
                      'Fecha: ${multa.fechaInfraccion.day}/${multa.fechaInfraccion.month}/${multa.fechaInfraccion.year}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'editar') {
                          _mostrarDialogoMulta(
                            context,
                            multaAEditar: multa,
                            index: index,
                          );
                        } else if (value == 'borrar') {
                          _borrarMulta(index);
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
        onPressed: () => _mostrarDialogoMulta(context),
        icon: const Icon(Icons.add),
        label: const Text('Añadir Multa'),
      ),
    );
  }

  void _mostrarDialogoMulta(
    BuildContext context, {
    Multa? multaAEditar,
    int? index,
  }) {
    final esEdicion = multaAEditar != null;

    final motivoCtrl = TextEditingController(text: multaAEditar?.motivo ?? '');
    final importeCtrl = TextEditingController(
      text: multaAEditar?.importe.toString() ?? '',
    );
    final puntosCtrl = TextEditingController(
      text: multaAEditar?.puntosDetraidos.toString() ?? '0',
    );
    DateTime fecha = multaAEditar?.fechaInfraccion ?? DateTime.now();
    bool pagada = multaAEditar?.pagada ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(esEdicion ? 'Editar Multa' : 'Añadir Multa'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: motivoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Motivo (ej. Exceso de velocidad)',
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: importeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Importe (€)',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: puntosCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Puntos (-)',
                              hintText: '0',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text('¿Está pagada?'),
                      value: pagada,
                      activeThumbColor: Colors.green,
                      onChanged: (valor) =>
                          setStateDialog(() => pagada = valor),
                    ),
                    ListTile(
                      title: const Text('Fecha Infracción'),
                      subtitle: Text(
                        '${fecha.day}/${fecha.month}/${fecha.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final fechaEscogida = await showDatePicker(
                          context: context,
                          initialDate: fecha,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (fechaEscogida != null) {
                          setStateDialog(() => fecha = fechaEscogida);
                        }
                      },
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
                    final nuevaMulta = Multa(
                      fechaInfraccion: fecha,
                      motivo: motivoCtrl.text,
                      importe: double.tryParse(importeCtrl.text) ?? 0.0,
                      puntosDetraidos: int.tryParse(puntosCtrl.text) ?? 0,
                      pagada: pagada,
                    );

                    setState(() {
                      final nuevaLista = List<Multa>.from(
                        widget.vehiculo.multas,
                      );
                      if (esEdicion) {
                        nuevaLista[index!] = nuevaMulta;
                      } else {
                        nuevaLista.add(nuevaMulta);
                      }
                      nuevaLista.sort(
                        (a, b) =>
                            b.fechaInfraccion.compareTo(a.fechaInfraccion),
                      );
                      widget.vehiculo.multas = nuevaLista;
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
      },
    );
  }

  void _borrarMulta(int index) {
    setState(() {
      final nuevaLista = List<Multa>.from(widget.vehiculo.multas);
      nuevaLista.removeAt(index);
      widget.vehiculo.multas = nuevaLista;
    });
    widget.onChanged();
  }
}
