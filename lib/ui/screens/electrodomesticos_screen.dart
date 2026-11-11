import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/hogar/electrodomestico.dart';
import '../../models/hogar/propiedad.dart';
import '../../providers/usuario_provider.dart';
import 'add_electrodomestico_screen.dart';
import '../theme/app_theme.dart';

class ElectrodomesticosScreen extends StatefulWidget {
  final Propiedad propiedad;
  const ElectrodomesticosScreen({super.key, required this.propiedad});

  @override
  State<ElectrodomesticosScreen> createState() => _ElectrodomesticosScreenState();
}

class _ElectrodomesticosScreenState extends State<ElectrodomesticosScreen> {
  void _add() async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddElectrodomesticoScreen()));
    if (res is Electrodomestico && mounted) {
      setState(() {
        widget.propiedad.electrodomesticos.add(res);
        // Ordenamos mostrando arriba los que aún están en garantía
        widget.propiedad.electrodomesticos.sort((a, b) => b.estaEnGarantia == a.estaEnGarantia ? 0 : (a.estaEnGarantia ? -1 : 1));
        context.read<UsuarioProvider>().notify(propiedadParaGuardar: widget.propiedad);
      });
    }
  }

  void _borrar(Electrodomestico e) {
    setState(() {
      widget.propiedad.electrodomesticos.remove(e);
      context.read<UsuarioProvider>().notify();
    });
  }

  @override
  Widget build(BuildContext context) {
    final enseres = widget.propiedad.electrodomesticos;
    return Scaffold(
      appBar: AppBar(title: const Text('Electrodomésticos'), backgroundColor: Colors.orange, foregroundColor: Colors.white),
      body: enseres.isEmpty
        ? const Center(child: Text('El inventario está vacío.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: enseres.length,
            itemBuilder: (context, i) {
              final e = enseres[i];
              final enGarantia = e.estaEnGarantia;
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  leading: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const Padding(padding: EdgeInsets.all(5), child: FaIcon(FontAwesomeIcons.plug, color: Colors.orange, size: 30)),
                      if (enGarantia)
                        const Icon(Icons.verified, color: Colors.green, size: 16)
                    ],
                  ),
                  title: Text(e.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${e.marca} (${e.precio.toStringAsFixed(2)} €)\nComp: ${DateFormat('dd/MM/yyyy').format(e.fechaCompra)} - Ubic: ${e.ubicacion ?? 'S/D'}'),
                  trailing: enGarantia 
                      ? const Chip(label: Text('Garantía', style: TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: Colors.green, padding: EdgeInsets.zero)
                      : const Chip(label: Text('Sin Garant.', style: TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: AppTheme.textSecondary, padding: EdgeInsets.zero),
                  onLongPress: () => _borrar(e),
                ),
              );
            }
          ),
      floatingActionButton: FloatingActionButton.extended(backgroundColor: Colors.orange, foregroundColor: Colors.white, onPressed: _add, icon: const Icon(Icons.add), label: const Text('Añadir')),
    );
  }
}
