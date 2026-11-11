import 'package:flutter/material.dart';
import '../../models/vehiculos/vehiculo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/vehiculos/info_tab.dart';
import '../widgets/vehiculos/mantenimiento_tab.dart';
import '../widgets/vehiculos/itv_tab.dart';
import '../widgets/vehiculos/impuestos_tab.dart';
import '../widgets/vehiculos/seguro_tab.dart';
import '../widgets/vehiculos/multas_tab.dart';
import '../widgets/vehiculos/accidentes_tab.dart';

class VehiculoDetailScreen extends StatefulWidget {
  final Vehiculo vehiculo;

  const VehiculoDetailScreen({super.key, required this.vehiculo});

  @override
  State<VehiculoDetailScreen> createState() => _VehiculoDetailScreenState();
}

class _VehiculoDetailScreenState extends State<VehiculoDetailScreen> {
  // Función central para actualizar la pantalla general cuando cambian datos
  void _actualizarPantalla() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.vehiculo.marca} ${widget.vehiculo.modelo}'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: FaIcon(FontAwesomeIcons.circleInfo, size: 20), text: 'Info'),
              Tab(icon: FaIcon(FontAwesomeIcons.wrench, size: 20), text: 'Mantenimiento'),
              Tab(icon: FaIcon(FontAwesomeIcons.clipboardCheck, size: 20), text: 'ITV'),
              Tab(icon: FaIcon(FontAwesomeIcons.landmark, size: 20), text: 'Impuestos'),
              Tab(icon: FaIcon(FontAwesomeIcons.shieldHalved, size: 20), text: 'Seguro'),
              Tab(icon: FaIcon(FontAwesomeIcons.fileInvoiceDollar, size: 20), text: 'Multas'),
              Tab(icon: FaIcon(FontAwesomeIcons.carBurst, size: 20), text: 'Accidentes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            InfoTab(vehiculo: widget.vehiculo),
            MantenimientoTab(vehiculo: widget.vehiculo, onChanged: _actualizarPantalla),
            ITVTab(vehiculo: widget.vehiculo, onChanged: _actualizarPantalla),
            ImpuestosTab(vehiculo: widget.vehiculo, onChanged: _actualizarPantalla),
            SeguroTab(vehiculo: widget.vehiculo, onChanged: _actualizarPantalla),
            MultasTab(vehiculo: widget.vehiculo, onChanged: _actualizarPantalla),
            AccidentesTab(vehiculo: widget.vehiculo, onChanged: _actualizarPantalla),
          ],
        ),
      ),
    );
  }
}
