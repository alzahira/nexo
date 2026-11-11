import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/usuario_provider.dart';
import 'edit_menu_dia_screen.dart';
import '../theme/app_theme.dart';

class MenuSemanalScreen extends StatefulWidget {
  const MenuSemanalScreen({super.key});

  @override
  State<MenuSemanalScreen> createState() => _MenuSemanalScreenState();
}

class _MenuSemanalScreenState extends State<MenuSemanalScreen> {
  @override
  Widget build(BuildContext context) {
    final menu = context.watch<UsuarioProvider>().menuSemanal;
    return Scaffold(
      appBar: AppBar(title: const Text('Menú de la Semana'), backgroundColor: Colors.orange, foregroundColor: Colors.white),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: menu.length,
        itemBuilder: (context, i) {
          final dia = menu[i];
          final tieneComida = dia.desayuno != null || dia.almuerzo != null || dia.cena != null;
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ExpansionTile(
              leading: CircleAvatar(backgroundColor: Colors.orange.shade100, child: Text(dia.diaSemana[0], style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
              title: Text(dia.diaSemana, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(tieneComida ? 'Planificado' : 'Sin planificar', style: TextStyle(color: tieneComida ? Colors.green : AppTheme.textSecondary)),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                onPressed: () async {
                  final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditMenuDiaScreen(menu: dia)));
                  if (res != null && context.mounted) {
                    context.read<UsuarioProvider>().actualizarMenu(i, res['desayuno'], res['almuerzo'], res['cena']);
                  }
                },
              ),
              children: [
                _comidaInfo('Desayuno', dia.desayuno, Icons.coffee),
                _comidaInfo('Almuerzo', dia.almuerzo, Icons.restaurant),
                _comidaInfo('Cena', dia.cena, Icons.nightlight_round),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _comidaInfo(String label, String? valor, IconData icono) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 16, color: Colors.orange),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                Text(valor ?? 'No definido', style: TextStyle(fontSize: 14, fontStyle: valor == null ? FontStyle.italic : FontStyle.normal, color: valor == null ? AppTheme.textSecondary : Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
