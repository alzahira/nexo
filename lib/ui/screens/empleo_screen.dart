import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../../models/usuarios/persona.dart';
import 'edit_datos_empleo_screen.dart';
import '../../models/trabajo/nomina.dart';
import 'nominas_screen.dart';
import 'contratos_screen.dart';

class EmpleoScreen extends StatefulWidget {
  final Persona persona;
  const EmpleoScreen({super.key, required this.persona});

  @override
  State<EmpleoScreen> createState() => _EmpleoScreenState();
}

class _EmpleoScreenState extends State<EmpleoScreen> {
  void _editDatos() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => EditDatosEmpleoScreen(persona: widget.persona))).then((_) => setState(() {}));
  }

  Widget _buildCard(String titulo, FaIconData icono, Color color, VoidCallback onTap) {
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
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoNominas(List<Nomina> nominas) {
    final now = DateTime.now();
    List<Map<String, dynamic>> ultimos12 = [];
    double maxValor = 0;
    double totalAcumulado = 0;

    for (int i = 11; i >= 0; i--) {
      int m = now.month - i;
      int y = now.year;
      if (m <= 0) {
        m += 12;
        y -= 1;
      }
      
      double importe = nominas.where((n) => n.mes == m && n.ano == y).fold(0.0, (prev, n) => prev + n.importeLiquido);
      if (importe > maxValor) maxValor = importe;
      totalAcumulado += importe;

      ultimos12.add({
        'label': '${m.toString().padLeft(2, '0')}/${y.toString().substring(2)}',
        'valor': importe,
      });
    }

    if (maxValor == 0) maxValor = 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Ingresos Últimos 12 Meses', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textPrimary)),
          const SizedBox(height: 5),
          Text('${totalAcumulado.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: AppTheme.accentGlow)),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ultimos12.map((data) {
                double heightFactor = data['valor'] / maxValor;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (data['valor'] > 0)
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: heightFactor,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                borderRadius: BorderRadius.circular(4)
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 5),
                      Text(data['label'], style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                    ],
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emp = widget.persona.rolEmpleado;
    return Scaffold(
      appBar: AppBar(
        title: Text('Empleo - ${widget.persona.nombre}'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editDatos, tooltip: 'Editar Perfil'),
        ],
      ),
      body: Column(
        children: [
          // Tarjeta Resumen
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
                  child: Icon(Icons.business_center, size: 36, color: AppTheme.accentGlow),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(emp?.empresaActual.isNotEmpty == true ? emp!.empresaActual : 'Sin Empresa', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 5),
                      Text(emp?.puesto.isNotEmpty == true ? emp!.puesto : 'Puesto no definido', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                      if (emp != null)
                        Text('Ingreso: ${DateFormat('dd/MM/yyyy').format(emp.fechaIngreso)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Gráfico de Nóminas
          if (emp != null) _buildGraficoNominas(emp.nominas),
          const SizedBox(height: 10),
          // Botonera Módulos (UML: Nóminas y Contratos)
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildCard('Nóminas', FontAwesomeIcons.fileInvoiceDollar, Colors.blue, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => NominasScreen(persona: widget.persona)));
                }),
                _buildCard('Contratos', FontAwesomeIcons.fileSignature, Colors.brown, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ContratosScreen(persona: widget.persona)));
                }),
              ],
            ),
          ),
        ],
      )
    );
  }
}
