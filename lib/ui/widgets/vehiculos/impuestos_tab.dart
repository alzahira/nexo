import 'package:flutter/material.dart';
import '../../../models/vehiculos/vehiculo.dart';
import '../../../models/vehiculos/impuesto_circulacion.dart';

class ImpuestosTab extends StatefulWidget {
  final Vehiculo vehiculo;
  final VoidCallback onChanged;

  const ImpuestosTab({super.key, required this.vehiculo, required this.onChanged});

  @override
  State<ImpuestosTab> createState() => _ImpuestosTabState();
}

class _ImpuestosTabState extends State<ImpuestosTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.vehiculo.historialImpuestos.isEmpty
          ? const Center(child: Text('No hay registros de impuestos.'))
          : ListView.builder(
              itemCount: widget.vehiculo.historialImpuestos.length,
              itemBuilder: (context, index) {
                final impuesto = widget.vehiculo.historialImpuestos[index];
                final vencido =
                    !impuesto.pagado &&
                    DateTime.now().isAfter(impuesto.fechaLimitePago);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: vencido
                          ? Colors.red.shade300
                          : (impuesto.pagado
                                ? Colors.green.shade300
                                : Colors.transparent),
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      impuesto.pagado
                          ? Icons.check_circle
                          : (vencido ? Icons.warning : Icons.pending_actions),
                      color: impuesto.pagado
                          ? Colors.green
                          : (vencido ? Colors.red : Colors.orange),
                      size: 36,
                    ),
                    title: Text(
                      'Impuesto de Circulación ${impuesto.anio}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Importe: ${impuesto.importe} €\n'
                      'Límite de pago: ${impuesto.fechaLimitePago.day}/${impuesto.fechaLimitePago.month}/${impuesto.fechaLimitePago.year}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'editar') {
                          _mostrarDialogoImpuesto(
                            context,
                            impAEditar: impuesto,
                            index: index,
                          );
                        } else if (value == 'borrar') {
                          _borrarImpuesto(index);
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
        onPressed: () => _mostrarDialogoImpuesto(context),
        icon: const Icon(Icons.add),
        label: const Text('Añadir Impuesto'),
      ),
    );
  }

  void _mostrarDialogoImpuesto(
    BuildContext context, {
    ImpuestoCirculacion? impAEditar,
    int? index,
  }) {
    final esEdicion = impAEditar != null;

    final anioCtrl = TextEditingController(
      text: impAEditar?.anio.toString() ?? DateTime.now().year.toString(),
    );
    final importeCtrl = TextEditingController(
      text: impAEditar?.importe.toString() ?? '',
    );
    bool pagado = impAEditar?.pagado ?? false;
    DateTime fechaLimite =
        impAEditar?.fechaLimitePago ?? DateTime(DateTime.now().year, 5, 31);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(esEdicion ? 'Editar Impuesto' : 'Añadir Impuesto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: anioCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Año (Ej. 2026)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: importeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Importe (€)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text('¿Está pagado?'),
                      value: pagado,
                      activeThumbColor: Colors.green,
                      onChanged: (valor) =>
                          setStateDialog(() => pagado = valor),
                    ),
                    ListTile(
                      title: const Text('Fecha Límite'),
                      subtitle: Text(
                        '${fechaLimite.day}/${fechaLimite.month}/${fechaLimite.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: fechaLimite,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (fecha != null) {
                          setStateDialog(() => fechaLimite = fecha);
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
                    final nuevoImpuesto = ImpuestoCirculacion(
                      anio: int.tryParse(anioCtrl.text) ?? DateTime.now().year,
                      importe: double.tryParse(importeCtrl.text) ?? 0.0,
                      pagado: pagado,
                      fechaLimitePago: fechaLimite,
                    );

                    setState(() {
                      final nuevaLista = List<ImpuestoCirculacion>.from(
                        widget.vehiculo.historialImpuestos,
                      );
                      if (esEdicion) {
                        nuevaLista[index!] = nuevoImpuesto;
                      } else {
                        nuevaLista.add(nuevoImpuesto);
                      }
                      nuevaLista.sort((a, b) => b.anio.compareTo(a.anio));
                      widget.vehiculo.historialImpuestos = nuevaLista;
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

  void _borrarImpuesto(int index) {
    setState(() {
      final nuevaLista = List<ImpuestoCirculacion>.from(
        widget.vehiculo.historialImpuestos,
      );
      nuevaLista.removeAt(index);
      widget.vehiculo.historialImpuestos = nuevaLista;
    });
    widget.onChanged();
  }
}
