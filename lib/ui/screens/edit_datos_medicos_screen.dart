import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/usuarios/persona.dart';
import '../../providers/usuario_provider.dart';

class EditDatosMedicosScreen extends StatefulWidget {
  final Persona persona;
  const EditDatosMedicosScreen({super.key, required this.persona});

  @override
  State<EditDatosMedicosScreen> createState() => _EditDatosMedicosScreenState();
}

class _EditDatosMedicosScreenState extends State<EditDatosMedicosScreen> {
  late TextEditingController _alergiasCtrl;
  late TextEditingController _medicoCtrl;
  late TextEditingController _centroCtrl;
  late TextEditingController _ssCtrl;

  @override
  void initState() {
    super.initState();
    // Cargamos los datos actuales de la persona
    _alergiasCtrl = TextEditingController(text: widget.persona.alergiasConocidas);
    _medicoCtrl = TextEditingController(text: widget.persona.medicoCabecera);
    _centroCtrl = TextEditingController(text: widget.persona.centroMedico);
    _ssCtrl = TextEditingController(text: widget.persona.numSeguridadSocial);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Datos Médicos')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildField(_alergiasCtrl, 'Alergias Conocidas', Icons.warning_amber, Colors.red),
          _buildField(_medicoCtrl, 'Médico de Cabecera', Icons.person, Colors.blue),
          _buildField(_centroCtrl, 'Centro Médico', Icons.local_hospital, Colors.teal),
          _buildField(_ssCtrl, 'Nº Seguridad Social', Icons.badge, Colors.blueGrey),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              // Guardamos los cambios en el objeto persona
              widget.persona.alergiasConocidas = _alergiasCtrl.text;
              widget.persona.medicoCabecera = _medicoCtrl.text;
              widget.persona.centroMedico = _centroCtrl.text;
              widget.persona.numSeguridadSocial = _ssCtrl.text;
              context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona);
              Navigator.pop(context, true); // Volvemos confirmando el cambio
            },
            child: const Text('Guardar Cambios', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: color),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}