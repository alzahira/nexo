import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/usuarios/ficha_tallas.dart';

class EditTallasScreen extends StatefulWidget {
  final FichaTallas? tallasActuales;
  const EditTallasScreen({super.key, this.tallasActuales});

  @override
  State<EditTallasScreen> createState() => _EditTallasScreenState();
}

class _EditTallasScreenState extends State<EditTallasScreen> {
  // 1. Controladores para cada campo del modelo
  final _camisaCtrl = TextEditingController();
  final _pantalonCtrl = TextEditingController();
  final _calzadoCtrl = TextEditingController();
  final _sujetadorCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 2. Cargamos los datos existentes si los hay
    if (widget.tallasActuales != null) {
      _camisaCtrl.text = widget.tallasActuales!.tallaCamisa;
      _pantalonCtrl.text = widget.tallasActuales!.tallaPantalon; // Corregido: antes decía talonPantalon
      _calzadoCtrl.text = widget.tallasActuales!.tallaCalzado.toString();
      _sujetadorCtrl.text = widget.tallasActuales!.tallaSujetador?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Ficha de Tallas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _campoTalla(_camisaCtrl, 'Talla Camisa', FontAwesomeIcons.shirt),
            _campoTalla(_pantalonCtrl, 'Talla Pantalón', FontAwesomeIcons.socks),
            _campoTalla(_calzadoCtrl, 'Talla Calzado', FontAwesomeIcons.shoePrints, isNumber: true),
            _campoTalla(_sujetadorCtrl, 'Talla Sujetador (Opcional)', FontAwesomeIcons.personDress, isNumber: true),
            
            const SizedBox(height: 30),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                // 3. Creamos el objeto con los tipos de datos correctos
                final nuevasTallas = FichaTallas(
                  tallaCamisa: _camisaCtrl.text,
                  tallaPantalon: _pantalonCtrl.text,
                  tallaCalzado: double.tryParse(_calzadoCtrl.text) ?? 0.0,
                  tallaSujetador: double.tryParse(_sujetadorCtrl.text), // Puede ser null
                );
                
                // Devolvemos el objeto a la pantalla anterior
                Navigator.pop(context, nuevasTallas);
              },
              child: const Text('Guardar Cambios', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoTalla(TextEditingController ctrl, String label, FaIconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: FaIcon(icon, size: 20, color: Colors.blueGrey),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}