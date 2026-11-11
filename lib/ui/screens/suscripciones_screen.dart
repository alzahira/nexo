import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/usuario_provider.dart';
import '../../models/gestion/suscripcion.dart';
import 'add_suscripcion_screen.dart';
import '../theme/app_theme.dart';

class SuscripcionesScreen extends StatefulWidget {
  const SuscripcionesScreen({super.key});

  @override
  State<SuscripcionesScreen> createState() => _SuscripcionesScreenState();
}

class _SuscripcionesScreenState extends State<SuscripcionesScreen> {
  void _add() async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSuscripcionScreen()));
    if (res is Suscripcion && mounted) {
      context.read<UsuarioProvider>().addSuscripcion(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suscripciones = context.watch<UsuarioProvider>().suscripciones;
    
    // Cálculo de gasto mensual real
    double gastoMensual = 0;
    for (var s in suscripciones) {
      if (s.periodicidad == 'Mensual') {
        gastoMensual += s.precio;
      } else {
        gastoMensual += s.precio / 12;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos y Suscripciones'), backgroundColor: Colors.purple, foregroundColor: Colors.white),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              border: Border(bottom: BorderSide(color: Colors.purple.shade100, width: 2))
            ),
            child: Column(
              children: [
                const Text('Gasto Mensual Estimado', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text('${gastoMensual.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.purple)),
                const Text('incluyendo prorrateo de anuales', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Expanded(
            child: suscripciones.isEmpty
              ? const Center(child: Text('No hay suscripciones registradas.', style: TextStyle(color: AppTheme.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: suscripciones.length,
                  itemBuilder: (context, i) {
                    final s = suscripciones[i];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.purple.shade100, child: const Icon(Icons.receipt_long, color: Colors.purple)),
                        title: Text(s.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${s.periodicidad} - Próximo: ${DateFormat('dd/MM').format(s.fechaProximoCobro)}'),
                        trailing: Text('${s.precio.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        onLongPress: () => context.read<UsuarioProvider>().removeSuscripcion(s),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.purple, foregroundColor: Colors.white, onPressed: _add, child: const Icon(Icons.add)),
    );
  }
}
