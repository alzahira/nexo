import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/usuario_provider.dart';
import '../theme/app_theme.dart';
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
        foregroundColor: AppTheme.textPrimary,
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
        gradient: AppTheme.mintGradient,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Resumen Mensual', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w700)),
              const Icon(Icons.analytics_rounded, color: AppTheme.accent),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('€', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w400)),
              Text(totalMensual.toStringAsFixed(2), style: const TextStyle(color: AppTheme.textPrimary, fontSize: 34, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniFicha(FontAwesomeIcons.basketShopping, '$pendientes items ptes'),
              Container(width: 1, height: 20, color: AppTheme.borderColor),
              _miniFicha(FontAwesomeIcons.calendarCheck, 'Menú OK'),
            ],
          )
        ],
      ),
    );
  }

  Widget _miniFicha(FaIconData icon, String text) {
    return Row(
      children: [
        FaIcon(icon, color: AppTheme.accentGlow, size: 14),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, FaIconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withValues(alpha: 0.18), width: 1.2)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.16),
              radius: 28,
              child: FaIcon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
