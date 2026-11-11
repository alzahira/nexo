import 'package:flutter/material.dart';
import '../../models/gestion/menu_dia.dart';

class EditMenuDiaScreen extends StatefulWidget {
  final MenuDia menu;
  const EditMenuDiaScreen({super.key, required this.menu});

  @override
  State<EditMenuDiaScreen> createState() => _EditMenuDiaScreenState();
}

class _EditMenuDiaScreenState extends State<EditMenuDiaScreen> {
  late TextEditingController _desayunoCtrl;
  late TextEditingController _almuerzoCtrl;
  late TextEditingController _cenaCtrl;

  @override
  void initState() {
    super.initState();
    _desayunoCtrl = TextEditingController(text: widget.menu.desayuno);
    _almuerzoCtrl = TextEditingController(text: widget.menu.almuerzo);
    _cenaCtrl = TextEditingController(text: widget.menu.cena);
  }

  @override
  void dispose() {
    _desayunoCtrl.dispose(); _almuerzoCtrl.dispose(); _cenaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menú: ${widget.menu.diaSemana}'), backgroundColor: Colors.orange, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInput('Desayuno', _desayunoCtrl, Icons.coffee),
            const SizedBox(height: 20),
            _buildInput('Almuerzo / Comida', _almuerzoCtrl, Icons.restaurant),
            const SizedBox(height: 20),
            _buildInput('Cena', _cenaCtrl, Icons.nightlight_round),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'desayuno': _desayunoCtrl.text,
                    'almuerzo': _almuerzoCtrl.text,
                    'cena': _cenaCtrl.text,
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
                child: const Text('Actualizar Día'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, IconData icon) {
    return TextField(
      controller: ctrl,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.orange, width: 2)),
      ),
    );
  }
}
