import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/hogar/propiedad.dart';
import '../../providers/usuario_provider.dart';
import '../theme/app_theme.dart';
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

  String _euros(double v) {
    final s = v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2);
    return '$s €';
  }

  double _gastoInmueble(Propiedad p) {
    final reformas = p.reformas.fold(0.0, (prev, r) => prev + r.coste);
    final seguro = p.seguro?.primaAnual ?? 0.0;
    return reformas + seguro + p.ibi;
  }

  Widget _buildGastoPorInmueble(List<Propiedad> propiedades) {
    final gastos = <double>[for (final p in propiedades) _gastoInmueble(p)];
    final total = gastos.fold(0.0, (a, b) => a + b);
    final maxVal = gastos.isEmpty
        ? 0.0
        : gastos.reduce((a, b) => a > b ? a : b);
    final paleta = <Color>[
      AppTheme.accent,
      AppTheme.warningOrange,
      const Color(0xFFB98A7A),
      AppTheme.accentLight,
      AppTheme.successGreen,
      const Color(0xFF8C9EC4),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.softMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: AppTheme.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gasto por inmueble',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Reformas + seguro + IBI de cada casa',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (total > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Text(
                    _euros(total),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accentGlow,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (total <= 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Aún no hay gastos registrados. Añade reformas, seguro o IBI '
                'dentro de cada inmueble y aquí verás la comparación.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
              ),
            )
          else
            for (var i = 0; i < propiedades.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              _filaInmueble(
                propiedad: propiedades[i],
                gasto: gastos[i],
                max: maxVal,
                color: paleta[i % paleta.length],
              ),
            ],
          if (total > 0) ...[
            const SizedBox(height: 16),
            const Divider(color: AppTheme.borderColor, height: 1),
            const SizedBox(height: 12),
            const Text(
              'El IBI y el seguro son importes anuales; las reformas, un gasto único.',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _filaInmueble({
    required Propiedad propiedad,
    required double gasto,
    required double max,
    required Color color,
  }) {
    final proporcion = max <= 0 ? 0.0 : (gasto / max).clamp(0.0, 1.0);
    final reformas = propiedad.reformas.fold(0.0, (prev, r) => prev + r.coste);
    final seguro = propiedad.seguro?.primaAnual ?? 0.0;
    final detalle = 'Reformas ${_euros(reformas)} · Seguro ${_euros(seguro)} · IBI ${_euros(propiedad.ibi)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                propiedad.alias,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _euros(gasto),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: proporcion,
            minHeight: 9,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          detalle,
          style: const TextStyle(
            fontSize: 10.5,
            color: AppTheme.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _tarjetaPropiedad(Propiedad p) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PropiedadDetailScreen(propiedad: p)))
              .then((_) => setState(() {}));
        },
        onLongPress: () => _borrar(p),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: AppTheme.mintGradient,
            border: Border.all(color: AppTheme.borderColor),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0x2A6F9480),
                    child: FaIcon(FontAwesomeIcons.house, color: AppTheme.accentGlow),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      p.alias,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(p.direccion, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              const SizedBox(height: 10),
              const Divider(color: AppTheme.borderColor),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _miniIndicador(Icons.meeting_room, '${p.habitaciones.length} Cuartos'),
                  _miniIndicador(Icons.kitchen, '${p.electrodomesticos.length} Enseres'),
                  _miniIndicador(Icons.handyman, '${p.reformas.length} Reformas'),
                ],
              ),
            ],
          ),
        ),
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
                  const FaIcon(FontAwesomeIcons.houseChimneyWindow, size: 80, color: AppTheme.accentLight),
                  const SizedBox(height: 20),
                  const Text('No tienes propiedades registradas.', style: TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir Propiedad'),
                    onPressed: _addInfo,
                  ),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  children: [
                    _buildGastoPorInmueble(propiedades),
                    for (final p in propiedades) _tarjetaPropiedad(p),
                  ],
                ),
              ),
            ),
      floatingActionButton: propiedades.isNotEmpty
          ? FloatingActionButton(onPressed: _addInfo, child: const Icon(Icons.add))
          : null,
    );
  }

  Widget _miniIndicador(IconData icono, String texto) {
    return Column(
      children: [
        Icon(icono, color: AppTheme.accentGlow, size: 20),
        const SizedBox(height: 5),
        Text(texto, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
