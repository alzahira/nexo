import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/usuario_provider.dart';
import 'menu_semanal_screen.dart';
import 'lista_compra_screen.dart';
import 'suscripciones_screen.dart';
import 'suministros_screen.dart';

class GestionScreen extends StatelessWidget {
  const GestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión del Hogar'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatCard(context),
            const SizedBox(height: 25),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.9,
              children: [
                _buildOptionCard(
                  context,
                  'Menú\nSemanal',
                  FontAwesomeIcons.utensils,
                  Colors.orange,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuSemanalScreen()))
                ),
                _buildOptionCard(
                  context,
                  'Lista de\nla Compra',
                  FontAwesomeIcons.cartShopping,
                  Colors.green,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListaCompraScreen()))
                ),
                _buildOptionCard(
                  context,
                  'Gastos y\nSuscrip.',
                  FontAwesomeIcons.receipt,
                  Colors.purple,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuscripcionesScreen()))
                ),
                _buildOptionCard(
                  context,
                  'Servicios y\nSuministros',
                  FontAwesomeIcons.faucetDrip,
                  Colors.blue,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuministrosScreen()))
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context) {
    final prov = context.watch<UsuarioProvider>();
    final totalMensual = prov.suscripciones.fold(0.0, (p, s) => p + s.precio);
    final pendientes = prov.listaCompra.where((i) => !i.estaComprado).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3F51B5), Color(0xFF1A237E)]),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.indigo.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Resumen Mensual', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const Icon(Icons.analytics, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('€', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300)),
              Text(totalMensual.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniFicha(FontAwesomeIcons.basketShopping, '$pendientes items ptes'),
              Container(width: 1, height: 20, color: Colors.white24),
              _miniFicha(FontAwesomeIcons.calendarCheck, 'Menú OK'),
            ],
          )
        ],
      ),
    );
  }

  Widget _miniFicha(IconData icon, String text) {
    return Row(
      children: [
        FaIcon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 28,
              child: FaIcon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: color.withValues(alpha: 0.8), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
