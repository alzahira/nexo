import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/hogar/habitacion.dart';
import '../../models/hogar/propiedad.dart';
import '../../providers/usuario_provider.dart';
import 'add_habitacion_screen.dart';
import '../theme/app_theme.dart';

class HabitacionesScreen extends StatefulWidget {
  final Propiedad propiedad;
  const HabitacionesScreen({super.key, required this.propiedad});

  @override
  State<HabitacionesScreen> createState() => _HabitacionesScreenState();
}

class _HabitacionesScreenState extends State<HabitacionesScreen> {
  void _add() async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddHabitacionScreen()));
    if (res is Habitacion && mounted) {
      setState(() {
        widget.propiedad.habitaciones.add(res);
        context.read<UsuarioProvider>().notify(propiedadParaGuardar: widget.propiedad);
      });
    }
  }

  void _borrar(Habitacion h) {
    setState(() {
      widget.propiedad.habitaciones.remove(h);
      context.read<UsuarioProvider>().notify();
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitaciones = widget.propiedad.habitaciones;
    return Scaffold(
      appBar: AppBar(title: const Text('Estancias'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: habitaciones.isEmpty
        ? const Center(child: Text('No has registrado ninguna habitación.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: habitaciones.length,
            itemBuilder: (context, i) {
              final h = habitaciones[i];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  leading: const FaIcon(FontAwesomeIcons.bed, color: Colors.indigo, size: 30),
                  title: Text(h.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${h.tipo}\nColor: ${h.colorPared ?? 'S/D'} - Pintado: ${h.ultimaVezPintado != null ? DateFormat('dd/MM/yyyy').format(h.ultimaVezPintado!) : 'S/D'}'),
                  onLongPress: () => _borrar(h),
                ),
              );
            }
          ),
      floatingActionButton: FloatingActionButton.extended(backgroundColor: Colors.indigo, foregroundColor: Colors.white, onPressed: _add, icon: const Icon(Icons.add), label: const Text('Añadir')),
    );
  }
}
