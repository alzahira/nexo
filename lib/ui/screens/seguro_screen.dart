import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/hogar/propiedad.dart';
import '../../models/hogar/seguro_hogar.dart';
import '../theme/app_theme.dart';
import 'add_seguro_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/usuario_provider.dart';

class SeguroScreen extends StatefulWidget {
  final Propiedad propiedad;
  const SeguroScreen({super.key, required this.propiedad});

  @override
  State<SeguroScreen> createState() => _SeguroScreenState();
}

class _SeguroScreenState extends State<SeguroScreen> {
  void _editSeguro() async {
    final res = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => AddSeguroScreen(seguroExistente: widget.propiedad.seguro))
    );
    if (res is SeguroHogar && mounted) {
      setState(() {
        widget.propiedad.seguro = res;
        context.read<UsuarioProvider>().notify(propiedadParaGuardar: widget.propiedad);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.propiedad.seguro;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguro de Hogar'),
      ),
      body: s == null
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.shieldHeart, size: 80, color: AppTheme.accentLight),
                const SizedBox(height: 20),
                const Text('No hay seguro registrado en esta propiedad', style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _editSeguro, child: const Text('Registrar Seguro'))
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  color: AppTheme.bgCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: AppTheme.borderColor),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: AppTheme.peachGradient,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Compañía', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
                        Text(s.compania, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 15),
                        const Text('Número de Póliza', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
                        Text(s.nPoliza, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _datoSeguro(Icons.phone, 'Asistencia 24h', s.telefonoAsistencia, colorExtra: Colors.green),
                _datoSeguro(Icons.euro, 'Prima Anual', '${s.primaAnual.toStringAsFixed(2)} €'),
                _datoSeguro(Icons.calendar_month, 'Vencimiento', DateFormat('dd/MM/yyyy').format(s.fechaVencimiento)),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Datos del Seguro'),
                  onPressed: _editSeguro,
                )
              ],
            ),
          ),
    );
  }

  Widget _datoSeguro(IconData icono, String titulo, String valor, {Color? colorExtra}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icono, color: colorExtra ?? Colors.redAccent),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
