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


  Widget _desgloseGastos(Propiedad p) {
    final reformas = p.reformas.fold(0.0, (prev, r) => prev + r.coste);
    final seguro = p.seguro?.primaAnual ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 15, color: AppTheme.accentGlow),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Gastos de esta casa',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              Text(
                _euros(_gastoInmueble(p)),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _miniGasto(Icons.handyman_rounded, 'Reformas', reformas, AppTheme.warningOrange),
              _separadorGasto(),
              _miniGasto(Icons.shield_rounded, 'Seguro', seguro, AppTheme.accent),
              _separadorGasto(),
              _miniGasto(Icons.receipt_long_rounded, 'IBI', p.ibi, const Color(0xFF8C9EC4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _separadorGasto() {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppTheme.borderColor,
    );
  }

  Widget _miniGasto(IconData icono, String etiqueta, double valor, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 13, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  etiqueta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            _euros(valor),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
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
              const SizedBox(height: 14),
              _desgloseGastos(p),
              const SizedBox(height: 14),
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
                    const SizedBox(height: 8),
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
