import 'package:flutter/material.dart';
import '../../../models/vehiculos/vehiculo.dart';
import '../../../models/vehiculos/registro_itv.dart';

class ITVTab extends StatefulWidget {
  final Vehiculo vehiculo;
  final VoidCallback onChanged;

  const ITVTab({super.key, required this.vehiculo, required this.onChanged});

  @override
  State<ITVTab> createState() => _ITVTabState();
}

class _ITVTabState extends State<ITVTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.vehiculo.inspeccionesITV.isEmpty
          ? const Center(child: Text('No hay registros de ITV.'))
          : ListView.builder(
              itemCount: widget.vehiculo.inspeccionesITV.length,
              itemBuilder: (context, index) {
                final itv = widget.vehiculo.inspeccionesITV[index];
                final caducada = itv.estaCaducada();

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: caducada || !itv.esFavorable
                          ? Colors.red.shade300
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      itv.esFavorable ? Icons.verified : Icons.warning,
                      color: itv.esFavorable ? Colors.green : Colors.red,
                      size: 36,
                    ),
                    title: Text(
                      itv.esFavorable ? 'ITV Favorable' : 'ITV Desfavorable',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Pasada: ${itv.fechaInspeccion.day}/${itv.fechaInspeccion.month}/${itv.fechaInspeccion.year}\n'
                      'Vence: ${itv.fechaVencimiento.day}/${itv.fechaVencimiento.month}/${itv.fechaVencimiento.year}\n'
                      'Notas: ${itv.observaciones.isEmpty ? "Ninguna" : itv.observaciones}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'editar') {
                          _mostrarDialogoITV(
                            context,
                            itvAEditar: itv,
                            index: index,
                          );
                        } else if (value == 'borrar') {
                          _borrarITV(index);
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
        onPressed: () => _mostrarDialogoITV(context),
        icon: const Icon(Icons.add),
        label: const Text('Añadir ITV'),
      ),
    );
  }

  void _mostrarDialogoITV(
    BuildContext context, {
    RegistroITV? itvAEditar,
    int? index,
  }) {
    final esEdicion = itvAEditar != null;

    DateTime fechaInsp = itvAEditar?.fechaInspeccion ?? DateTime.now();
    DateTime fechaVenc =
        itvAEditar?.fechaVencimiento ??
        DateTime.now().add(const Duration(days: 365));
    bool favorable = itvAEditar?.esFavorable ?? true;
    final obsCtrl = TextEditingController(
      text: itvAEditar?.observaciones ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(esEdicion ? 'Editar ITV' : 'Nueva ITV'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('¿Favorable?'),
                      value: favorable,
                      activeThumbColor: Colors.green,
                      onChanged: (valor) =>
                          setStateDialog(() => favorable = valor),
                    ),
                    TextField(
                      controller: obsCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Observaciones (Opcional)',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 15),
                    ListTile(
                      title: const Text('Fecha Inspección'),
                      subtitle: Text(
                        '${fechaInsp.day}/${fechaInsp.month}/${fechaInsp.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final fechaEscogida = await showDatePicker(
                          context: context,
                          initialDate: fechaInsp,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (fechaEscogida != null) {
                          setStateDialog(() => fechaInsp = fechaEscogida);
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('Fecha Vencimiento'),
                      subtitle: Text(
                        '${fechaVenc.day}/${fechaVenc.month}/${fechaVenc.year}',
                      ),
                      trailing: const Icon(Icons.event_busy),
                      onTap: () async {
                        final fechaEscogida = await showDatePicker(
                          context: context,
                          initialDate: fechaVenc,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (fechaEscogida != null) {
                          setStateDialog(() => fechaVenc = fechaEscogida);
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
                    final nuevaITV = RegistroITV(
                      fechaInspeccion: fechaInsp,
                      esFavorable: favorable,
                      observaciones: obsCtrl.text,
                      fechaVencimiento: fechaVenc,
                    );

                    setState(() {
                      final nuevaLista = List<RegistroITV>.from(
                        widget.vehiculo.inspeccionesITV,
                      );
                      if (esEdicion) {
                        nuevaLista[index!] = nuevaITV;
                      } else {
                        nuevaLista.add(nuevaITV);
                      }
                      nuevaLista.sort(
                        (a, b) =>
                            b.fechaInspeccion.compareTo(a.fechaInspeccion),
                      );
                      widget.vehiculo.inspeccionesITV = nuevaLista;
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

  void _borrarITV(int index) {
    setState(() {
      final nuevaLista = List<RegistroITV>.from(
        widget.vehiculo.inspeccionesITV,
      );
      nuevaLista.removeAt(index);
      widget.vehiculo.inspeccionesITV = nuevaLista;
    });
    widget.onChanged();
  }
}
