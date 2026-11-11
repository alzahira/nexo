import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/usuarios/persona.dart';
import '../../models/trabajo/nomina.dart';
import '../../providers/usuario_provider.dart';
import 'add_nomina_screen.dart';
import '../theme/app_theme.dart';

class NominasScreen extends StatefulWidget {
  final Persona persona;
  const NominasScreen({super.key, required this.persona});

  @override
  State<NominasScreen> createState() => _NominasScreenState();
}

class _NominasScreenState extends State<NominasScreen> {
  void _add() async {
    final emp = widget.persona.rolEmpleado;
    if (emp == null) return;

    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddNominaScreen()));
    if (res is Nomina && mounted) {
      setState(() {
        emp.nominas.add(res);
        emp.nominas.sort((a, b) => b.ano.compareTo(a.ano) != 0 ? b.ano.compareTo(a.ano) : b.mes.compareTo(a.mes));
        context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona);
      });
    }
  }

  void _borrar(Nomina nomina) {
    setState(() {
      widget.persona.rolEmpleado?.nominas.remove(nomina);
      context.read<UsuarioProvider>().notify();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nominas = widget.persona.rolEmpleado?.nominas ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Nóminas'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: nominas.isEmpty
        ? const Center(child: Text('No hay nóminas registradas.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: nominas.length,
            itemBuilder: (context, i) {
              final n = nominas[i];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  leading: const FaIcon(FontAwesomeIcons.fileInvoiceDollar, color: Colors.blue, size: 30),
                  title: Text('Mes ${n.mes} / ${n.ano}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Importe Líquido: ${n.importeLiquido.toStringAsFixed(2)} €'),
                  trailing: n.archivoURL != null ? const Icon(Icons.attach_file, color: Colors.blue) : null,
                  onLongPress: () => _borrar(n),
                ),
              );
            }
          ),
      floatingActionButton: widget.persona.rolEmpleado != null
        ? FloatingActionButton.extended(backgroundColor: Colors.blue, foregroundColor: Colors.white, onPressed: _add, icon: const Icon(Icons.add), label: const Text('Añadir'))
        : null,
    );
  }
}
