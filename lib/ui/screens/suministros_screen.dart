import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/usuario_provider.dart';
import '../../models/gestion/suministro.dart';
import 'add_suministro_screen.dart';

class SuministrosScreen extends StatefulWidget {
  const SuministrosScreen({super.key});

  @override
  State<SuministrosScreen> createState() => _SuministrosScreenState();
}

class _SuministrosScreenState extends State<SuministrosScreen> {
  void _add() async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSuministroScreen()));
    if (res is Suministro && mounted) {
      context.read<UsuarioProvider>().addSuministro(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suministros = context.watch<UsuarioProvider>().suministros;
    return Scaffold(
      appBar: AppBar(title: const Text('Servicios y Suministros'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: suministros.isEmpty
        ? const Center(child: Text('Sin suministros registrados.', style: TextStyle(color: Colors.grey)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: suministros.length,
            itemBuilder: (context, i) {
              final s = suministros[i];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.all(5),
                    child: FaIcon(_getIconForTipo(s.tipo), color: Colors.blue, size: 28),
                  ),
                  title: Text(s.tipo, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${s.compania}\nContrato: ${s.nContrato ?? 'S/N'}'),
                  trailing: Text('${s.costeMesAnterior.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  onLongPress: () => context.read<UsuarioProvider>().removeSuministro(s),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.blue, foregroundColor: Colors.white, onPressed: _add, child: const Icon(Icons.add)),
    );
  }

  FaIconData _getIconForTipo(String tipo) {
    switch (tipo) {
      case 'Electricidad': return FontAwesomeIcons.bolt;
      case 'Agua': return FontAwesomeIcons.droplet;
      case 'Gas': return FontAwesomeIcons.fire;
      case 'Internet': return FontAwesomeIcons.wifi;
      case 'Teléfono': return FontAwesomeIcons.phone;
      case 'Seguridad': return FontAwesomeIcons.shieldHalved;
      default: return FontAwesomeIcons.fileContract;
    }
  }
}
