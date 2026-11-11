import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/hogar/propiedad.dart';
import '../theme/app_theme.dart';
import 'habitaciones_screen.dart';
import 'electrodomesticos_screen.dart';
import 'reformas_screen.dart';
import 'seguro_screen.dart';

class PropiedadDetailScreen extends StatefulWidget {
  final Propiedad propiedad;
  const PropiedadDetailScreen({super.key, required this.propiedad});

  @override
  State<PropiedadDetailScreen> createState() => _PropiedadDetailScreenState();
}

class _PropiedadDetailScreenState extends State<PropiedadDetailScreen> {

  Widget _buildBotonModulo(String titulo, FaIconData icono, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      color: AppTheme.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icono, color: color, size: 40),
            const SizedBox(height: 15),
            Text(titulo, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.propiedad;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.alias),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: AppTheme.mintGradient,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0x2A6F9480),
                  child: Icon(Icons.house, size: 38, color: AppTheme.accentGlow),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.direccion, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 5),
                      Text('IBI Anual: ${p.ibi} €', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                      if (p.valorCompra != null)
                        Text('Valor de Compra: ${p.valorCompra} €', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildBotonModulo('Habitaciones\ny Estancias', FontAwesomeIcons.bed, Colors.indigo, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => HabitacionesScreen(propiedad: widget.propiedad))).then((_) => setState(() {}));
                }),
                _buildBotonModulo('Garantías\ny Electro.', FontAwesomeIcons.plug, Colors.orange, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ElectrodomesticosScreen(propiedad: widget.propiedad))).then((_) => setState(() {}));
                }),
                _buildBotonModulo('Reformas\ny Obras', FontAwesomeIcons.hammer, Colors.brown, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ReformasScreen(propiedad: widget.propiedad))).then((_) => setState(() {}));
                }),
                _buildBotonModulo('Seguro\ny Pólizas', FontAwesomeIcons.shieldHeart, Colors.red, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SeguroScreen(propiedad: widget.propiedad))).then((_) => setState(() {}));
                }),
              ],
            ),
          ),
        ],
      )
    );
  }
}
