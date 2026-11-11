import 'package:flutter/material.dart';
import '../../../models/vehiculos/vehiculo.dart';
import '../../../models/vehiculos/poliza_seguro.dart';
import '../../theme/app_theme.dart';

class SeguroTab extends StatefulWidget {
  final Vehiculo vehiculo;
  final VoidCallback onChanged;

  const SeguroTab({super.key, required this.vehiculo, required this.onChanged});

  @override
  State<SeguroTab> createState() => _SeguroTabState();
}

class _SeguroTabState extends State<SeguroTab> {
  @override
  Widget build(BuildContext context) {
    final seguro = widget.vehiculo.seguroActual;

    return Scaffold(
      body: seguro == null
          ? const Center(
              child: Text(
                'No hay seguro registrado.\n¡Cuidado, no circules así!',
                textAlign: TextAlign.center,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: DateTime.now().isAfter(seguro.fechaVencimiento)
                        ? Colors.red.shade300
                        : Colors.green.shade300,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            seguro.compania.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'editar') {
                                _mostrarDialogoSeguro(
                                  context,
                                  seguroAEditar: seguro,
                                );
                              } else if (value == 'borrar') {
                                _borrarSeguro();
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
                        ],
                      ),
                      const Divider(height: 30),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.numbers, color: AppTheme.textSecondary),
                        title: const Text('Número de Póliza'),
                        subtitle: Text(
                          seguro.numeroPoliza,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.security, color: AppTheme.textSecondary),
                        title: const Text('Cobertura'),
                        subtitle: Text(
                          seguro.tipoCobertura,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.phone_in_talk,
                          color: Colors.orange,
                          size: 30,
                        ),
                        title: const Text('Asistencia en Carretera (Grúa)'),
                        subtitle: Text(
                          seguro.telefonoAsistencia,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          DateTime.now().isAfter(seguro.fechaVencimiento)
                              ? Icons.warning
                              : Icons.event_available,
                          color: DateTime.now().isAfter(seguro.fechaVencimiento)
                              ? Colors.red
                              : Colors.green,
                        ),
                        title: const Text('Vencimiento'),
                        subtitle: Text(
                          '${seguro.fechaVencimiento.day}/${seguro.fechaVencimiento.month}/${seguro.fechaVencimiento.year}',
                          style: TextStyle(
                            color:
                                DateTime.now().isAfter(seguro.fechaVencimiento)
                                ? Colors.red
                                : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: seguro == null
          ? FloatingActionButton.extended(
              onPressed: () => _mostrarDialogoSeguro(context),
              icon: const Icon(Icons.add),
              label: const Text('Añadir Seguro'),
            )
          : null,
    );
  }

  void _mostrarDialogoSeguro(
    BuildContext context, {
    SeguroVehiculo? seguroAEditar,
  }) {
    final esEdicion = seguroAEditar != null;

    final companiaCtrl = TextEditingController(
      text: seguroAEditar?.compania ?? '',
    );
    final polizaCtrl = TextEditingController(
      text: seguroAEditar?.numeroPoliza ?? '',
    );
    final coberturaCtrl = TextEditingController(
      text: seguroAEditar?.tipoCobertura ?? '',
    );
    final telefonoCtrl = TextEditingController(
      text: seguroAEditar?.telefonoAsistencia ?? '',
    );
    DateTime fechaVenc =
        seguroAEditar?.fechaVencimiento ??
        DateTime.now().add(const Duration(days: 365));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(esEdicion ? 'Editar Seguro' : 'Añadir Seguro'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: companiaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Compañía (ej. Mapfre)',
                      ),
                    ),
                    TextField(
                      controller: polizaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nº de Póliza',
                      ),
                    ),
                    TextField(
                      controller: coberturaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Cobertura (ej. Todo riesgo)',
                      ),
                    ),
                    TextField(
                      controller: telefonoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono de Grúa/Asistencia',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: const Text('Fecha Vencimiento'),
                      subtitle: Text(
                        '${fechaVenc.day}/${fechaVenc.month}/${fechaVenc.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: fechaVenc,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (fecha != null) {
                          setStateDialog(() => fechaVenc = fecha);
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
                    final nuevoSeguro = SeguroVehiculo(
                      compania: companiaCtrl.text,
                      numeroPoliza: polizaCtrl.text,
                      tipoCobertura: coberturaCtrl.text,
                      telefonoAsistencia: telefonoCtrl.text,
                      fechaVencimiento: fechaVenc,
                    );

                    setState(() {
                      widget.vehiculo.seguroActual = nuevoSeguro;
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

  void _borrarSeguro() {
    setState(() {
      widget.vehiculo.seguroActual = null;
    });
    widget.onChanged();
  }
}
