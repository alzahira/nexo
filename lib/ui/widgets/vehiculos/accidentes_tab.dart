import 'package:flutter/material.dart';
import '../../../models/vehiculos/vehiculo.dart';
import '../../../models/vehiculos/parte_accidente.dart';

class AccidentesTab extends StatefulWidget {
  final Vehiculo vehiculo;
  final VoidCallback onChanged;

  const AccidentesTab({super.key, required this.vehiculo, required this.onChanged});

  @override
  State<AccidentesTab> createState() => _AccidentesTabState();
}

class _AccidentesTabState extends State<AccidentesTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.vehiculo.partesAccidentes.isEmpty
          ? const Center(
              child: Text('Ningún accidente registrado. ¡Toca madera!'),
            )
          : ListView.builder(
              itemCount: widget.vehiculo.partesAccidentes.length,
              itemBuilder: (context, index) {
                final accidente = widget.vehiculo.partesAccidentes[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: accidente.hayHeridos
                          ? Colors.red.shade400
                          : Colors.orange.shade300,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.car_crash,
                      color: accidente.hayHeridos ? Colors.red : Colors.orange,
                      size: 36,
                    ),
                    title: Text(
                      'Golpe en ${accidente.lugar}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Contrario: ${accidente.matriculaContrario} (${accidente.companiaContrario})\n'
                      'Fecha: ${accidente.fechaHora.day}/${accidente.fechaHora.month}/${accidente.fechaHora.year}\n'
                      '${accidente.hayHeridos ? "⚠️ Hubo heridos\n" : ""}'
                      'Fotos adjuntas: ${accidente.fotosURLs.length}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'editar') {
                          _mostrarDialogoAccidente(
                            context,
                            accAEditar: accidente,
                            index: index,
                          );
                        } else if (value == 'borrar') {
                          _borrarAccidente(index);
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
        onPressed: () => _mostrarDialogoAccidente(context),
        icon: const Icon(Icons.add),
        label: const Text('Registrar Siniestro'),
        backgroundColor: Colors.orange.shade100,
        foregroundColor: Colors.orange.shade900,
      ),
    );
  }

  void _mostrarDialogoAccidente(
    BuildContext context, {
    ParteAccidente? accAEditar,
    int? index,
  }) {
    final esEdicion = accAEditar != null;

    final lugarCtrl = TextEditingController(text: accAEditar?.lugar ?? '');
    final descCtrl = TextEditingController(text: accAEditar?.descripcion ?? '');
    final matriCtrl = TextEditingController(
      text: accAEditar?.matriculaContrario ?? '',
    );
    final compaCtrl = TextEditingController(
      text: accAEditar?.companiaContrario ?? '',
    );
    bool heridos = accAEditar?.hayHeridos ?? false;
    DateTime fecha = accAEditar?.fechaHora ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(esEdicion ? 'Editar Siniestro' : 'Nuevo Siniestro'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: lugarCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Lugar (ej. Rotonda M-40)',
                      ),
                    ),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descripción de los daños',
                      ),
                      maxLines: 2,
                    ),
                    const Divider(),
                    const Text(
                      'Datos del contrario',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: matriCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Matrícula del otro coche',
                      ),
                    ),
                    TextField(
                      controller: compaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Compañía aseguradora',
                      ),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('¿Hubo heridos?'),
                      value: heridos,
                      activeThumbColor: Colors.red,
                      onChanged: (valor) =>
                          setStateDialog(() => heridos = valor),
                    ),
                    ListTile(
                      title: const Text('Fecha del siniestro'),
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
                    final nuevoAccidente = ParteAccidente(
                      fechaHora: fecha,
                      lugar: lugarCtrl.text,
                      descripcion: descCtrl.text,
                      matriculaContrario: matriCtrl.text,
                      companiaContrario: compaCtrl.text,
                      hayHeridos: heridos,
                      fotosURLs: esEdicion
                          ? accAEditar.fotosURLs
                          : [],
                    );

                    setState(() {
                      final nuevaLista = List<ParteAccidente>.from(
                        widget.vehiculo.partesAccidentes,
                      );
                      if (esEdicion) {
                        nuevaLista[index!] = nuevoAccidente;
                      } else {
                        nuevaLista.add(nuevoAccidente);
                      }
                      nuevaLista.sort(
                        (a, b) => b.fechaHora.compareTo(a.fechaHora),
                      );
                      widget.vehiculo.partesAccidentes = nuevaLista;
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

  void _borrarAccidente(int index) {
    setState(() {
      final nuevaLista = List<ParteAccidente>.from(
        widget.vehiculo.partesAccidentes,
      );
      nuevaLista.removeAt(index);
      widget.vehiculo.partesAccidentes = nuevaLista;
    });
    widget.onChanged();
  }
}
