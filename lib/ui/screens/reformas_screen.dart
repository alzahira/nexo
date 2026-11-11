import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/hogar/reforma.dart';
import '../../models/hogar/propiedad.dart';
import '../../providers/usuario_provider.dart';
import 'add_reforma_screen.dart';
import '../theme/app_theme.dart';

class ReformasScreen extends StatefulWidget {
  final Propiedad propiedad;
  const ReformasScreen({super.key, required this.propiedad});

  @override
  State<ReformasScreen> createState() => _ReformasScreenState();
}

class _ReformasScreenState extends State<ReformasScreen> {
  void _add() async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddReformaScreen()));
    if (res is Reforma && mounted) {
      setState(() {
        widget.propiedad.reformas.add(res);
        // Ordenamos por fecha más reciente
        widget.propiedad.reformas.sort((a, b) => b.fechaFin.compareTo(a.fechaFin));
        context.read<UsuarioProvider>().notify(propiedadParaGuardar: widget.propiedad);
      });
    }
  }

  void _borrar(Reforma r) {
    setState(() {
      widget.propiedad.reformas.remove(r);
      context.read<UsuarioProvider>().notify();
    });
  }

  @override
  Widget build(BuildContext context) {
    final obras = widget.propiedad.reformas;
    final costeTotal = obras.fold(0.0, (prev, o) => prev + o.coste);

    return Scaffold(
      appBar: AppBar(title: const Text('Obras y Mantenimiento'), backgroundColor: Colors.brown, foregroundColor: Colors.white),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.brown.shade100,
            child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 const Text('Inversión Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
                 Text('${costeTotal.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown)),
               ],
            ),
          ),
          Expanded(
            child: obras.isEmpty
              ? const Center(child: Text('Sin reformas registradas.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: obras.length,
                  itemBuilder: (context, i) {
                    final r = obras[i];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ListTile(
                        leading: const Padding(padding: EdgeInsets.all(5), child: FaIcon(FontAwesomeIcons.hammer, color: Colors.brown, size: 28)),
                        title: Text(r.descripcion, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${r.contratista}\nFecha Fin: ${DateFormat('dd/MM/yyyy').format(r.fechaFin)}'),
                        trailing: Text('${r.coste.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                        onLongPress: () => _borrar(r),
                      ),
                    );
                  }
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(backgroundColor: Colors.brown, foregroundColor: Colors.white, onPressed: _add, icon: const Icon(Icons.add), label: const Text('Registrar Obra')),
    );
  }
}
