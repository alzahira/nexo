import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/hogar/propiedad.dart';
import '../../providers/usuario_provider.dart';
import 'add_propiedad_screen.dart';
import 'propiedad_detail_screen.dart';

class HogarScreen extends StatefulWidget {
  const HogarScreen({super.key});

  @override
  State<HogarScreen> createState() => _HogarScreenState();
}

class _HogarScreenState extends State<HogarScreen> {
  void _addInfo() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropiedadScreen()));
    if (result is Propiedad && mounted) {
      context.read<UsuarioProvider>().addPropiedad(result);
    }
  }

  void _borrar(Propiedad p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Propiedad'),
        content: Text('¿Seguro que deseas eliminar "${p.alias}" y todo lo que contiene?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              context.read<UsuarioProvider>().removePropiedad(p);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      )
    );
  }

  Widget _buildGraficoInversion(List<Propiedad> propiedades) {
    double totalReformas = 0;
    double totalSeguros = 0;
    
    for (var p in propiedades) {
      totalReformas += p.reformas.fold(0.0, (prev, r) => prev + r.coste);
      if (p.seguro != null) totalSeguros += p.seguro!.primaAnual;
    }

    double maxVal = totalReformas > totalSeguros ? totalReformas : totalSeguros;
    if (maxVal == 0) maxVal = 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Inversión Patrimonial Global', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _barra(totalReformas, maxVal, 'Reformas', Colors.brown),
              const SizedBox(width: 20),
              _barra(totalSeguros, maxVal, 'Seguros', Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _barra(double valor, double max, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text('${valor.toStringAsFixed(0)}€', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Container(
            height: 60 * (valor / max),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final propiedades = context.watch<UsuarioProvider>().propiedades;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Inmuebles'), centerTitle: true, elevation: 0),
      body: propiedades.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.houseChimneyWindow, size: 80, color: Colors.blueGrey),
                const SizedBox(height: 20),
                const Text('No tienes propiedades registradas.', style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir Propiedad'),
                  onPressed: _addInfo,
                )
              ],
            )
          )
        : Column(
            children: [
              _buildGraficoInversion(propiedades),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: propiedades.length,
                  itemBuilder: (context, i) {
                    final p = propiedades[i];
              return Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PropiedadDetailScreen(propiedad: p))).then((_) => setState(() {}));
                  },
                  onLongPress: () => _borrar(p),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade700, Colors.teal.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(backgroundColor: Colors.white24, child: FaIcon(FontAwesomeIcons.house, color: Colors.white)),
                            const SizedBox(width: 15),
                            Expanded(child: Text(p.alias, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(p.direccion, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 10),
                        const Divider(color: Colors.white24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _miniIndicador(Icons.meeting_room, '${p.habitaciones.length} Cuartos'),
                            _miniIndicador(Icons.kitchen, '${p.electrodomesticos.length} Enseres'),
                            _miniIndicador(Icons.handyman, '${p.reformas.length} Reformas'),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                  );
                },
              ),
            ),
          ],
        ),
      floatingActionButton: propiedades.isNotEmpty
        ? FloatingActionButton(onPressed: _addInfo, backgroundColor: Colors.teal, child: const Icon(Icons.add))
        : null,
    );
  }

  Widget _miniIndicador(IconData icono, String texto) {
    return Column(
      children: [
        Icon(icono, color: Colors.white, size: 20),
        const SizedBox(height: 5),
        Text(texto, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
