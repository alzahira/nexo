import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/usuarios/persona.dart';
import '../../models/trabajo/contrato.dart';
import '../../providers/usuario_provider.dart';
import 'add_contrato_screen.dart';
import '../theme/app_theme.dart';

class ContratosScreen extends StatefulWidget {
  final Persona persona;
  const ContratosScreen({super.key, required this.persona});

  @override
  State<ContratosScreen> createState() => _ContratosScreenState();
}

class _ContratosScreenState extends State<ContratosScreen> {
  void _add() async {
    final emp = widget.persona.rolEmpleado;
    if (emp == null) return;

    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddContratoScreen()));
    if (res is Contrato && mounted) {
      setState(() {
        emp.contratos.add(res);
        emp.contratos.sort((a, b) => b.fechaInicio.compareTo(a.fechaInicio));
        context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona);
      });
    }
  }

  void _borrar(Contrato contrato) {
    setState(() {
      widget.persona.rolEmpleado?.contratos.remove(contrato);
      context.read<UsuarioProvider>().notify();
    });
  }

  @override
  Widget build(BuildContext context) {
    final contratos = widget.persona.rolEmpleado?.contratos ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Contratos'), backgroundColor: Colors.brown, foregroundColor: Colors.white),
      body: contratos.isEmpty
        ? const Center(child: Text('No hay contratos registrados.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contratos.length,
            itemBuilder: (context, i) {
              final c = contratos[i];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  leading: const FaIcon(FontAwesomeIcons.fileSignature, color: Colors.brown, size: 30),
                  title: Text(c.tipoContrato, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Ref: ${c.identificadorContrato}\nInicio: ${DateFormat('dd/MM/yyyy').format(c.fechaInicio)}${c.fechaFin != null ? ' - Fin: ${DateFormat('dd/MM/yyyy').format(c.fechaFin!)}' : ' (Indefinido)'}'),
                  trailing: c.archivoURL != null ? const Icon(Icons.attach_file, color: Colors.brown) : null,
                  onLongPress: () => _borrar(c),
                ),
              );
            }
          ),
      floatingActionButton: widget.persona.rolEmpleado != null
        ? FloatingActionButton.extended(backgroundColor: Colors.brown, foregroundColor: Colors.white, onPressed: _add, icon: const Icon(Icons.add), label: const Text('Añadir'))
        : null,
    );
  }
}
