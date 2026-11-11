import 'package:flutter/material.dart';
import '../../models/usuarios/persona.dart';
import '../../models/educacion/pago_educacion.dart';
import '../../providers/usuario_provider.dart';
import 'package:provider/provider.dart';
import 'add_pago_educacion_screen.dart';
import '../theme/app_theme.dart';

class PagosEducacionScreen extends StatefulWidget {
  final Persona persona;
  const PagosEducacionScreen({super.key, required this.persona});

  @override
  State<PagosEducacionScreen> createState() => _PagosEducacionScreenState();
}

class _PagosEducacionScreenState extends State<PagosEducacionScreen> {
  void _add() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPagoEducacionScreen()));
    if (result is PagoEducacion && context.mounted) {
      setState(() {
        widget.persona.rolEstudiante?.pagos.add(result);
        context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona);
      });
    }
  }

  void _borrar(PagoEducacion p) {
    setState(() {
      widget.persona.rolEstudiante?.pagos.remove(p);
      context.read<UsuarioProvider>().notify();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pagos = widget.persona.rolEstudiante?.pagos ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Mensualidades y Pagos'), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: pagos.isEmpty 
          ? const Center(child: Text('No hay pagos vinculados', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16))) 
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pagos.length,
              itemBuilder: (c, i) {
                final p = pagos[i];
                return Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long, color: Colors.teal, size: 30),
                    title: Text(p.concepto, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Cobro: ${p.periodicidad}'),
                    trailing: IconButton(icon: const Icon(Icons.delete, color: AppTheme.textSecondary), onPressed: () => _borrar(p)),
                  ),
                );
              }
            ),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.teal, foregroundColor: Colors.white, onPressed: _add, child: const Icon(Icons.add)),
    );
  }
}
