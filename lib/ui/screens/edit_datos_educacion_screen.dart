import 'package:flutter/material.dart';
import '../../models/usuarios/persona.dart';
import '../../models/educacion/alumno.dart';
import '../../providers/usuario_provider.dart';
import 'package:provider/provider.dart';

class EditDatosEducacionScreen extends StatefulWidget {
  final Persona persona;
  const EditDatosEducacionScreen({super.key, required this.persona});

  @override
  State<EditDatosEducacionScreen> createState() => _EditDatosEducacionScreenState();
}

class _EditDatosEducacionScreenState extends State<EditDatosEducacionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _centroCtrl;
  late TextEditingController _cursoCtrl;
  late TextEditingController _idEscolarCtrl;
  late TextEditingController _tutorCtrl;
  late TextEditingController _userIpasenCtrl;
  late TextEditingController _passIpasenCtrl;
  late TextEditingController _userLibrosCtrl;
  late TextEditingController _passLibrosCtrl;
  late TextEditingController _classroomCtrl;

  @override
  void initState() {
    super.initState();
    final a = widget.persona.rolEstudiante;
    _centroCtrl = TextEditingController(text: a?.centroEducativo ?? '');
    _cursoCtrl = TextEditingController(text: a?.curso ?? '');
    _idEscolarCtrl = TextEditingController(text: a?.identificadorEscolar ?? '');
    _tutorCtrl = TextEditingController(text: a?.tutor ?? '');
    _userIpasenCtrl = TextEditingController(text: a?.usuarioIpasen ?? '');
    _passIpasenCtrl = TextEditingController(text: a?.passIpasen ?? '');
    _userLibrosCtrl = TextEditingController(text: a?.usuarioLibros ?? '');
    _passLibrosCtrl = TextEditingController(text: a?.passLibros ?? '');
    _classroomCtrl = TextEditingController(text: a?.conectarConClassroom ?? '');
  }

  @override
  void dispose() {
    _centroCtrl.dispose();
    _cursoCtrl.dispose();
    _idEscolarCtrl.dispose();
    _tutorCtrl.dispose();
    _userIpasenCtrl.dispose();
    _passIpasenCtrl.dispose();
    _userLibrosCtrl.dispose();
    _passLibrosCtrl.dispose();
    _classroomCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha del Alumno'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Datos Académicos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
              const SizedBox(height: 10),
              _crearCampo('Centro Educativo', _centroCtrl, Icons.school),
              _crearCampo('Curso / Nivel', _cursoCtrl, Icons.stairs),
              _crearCampo('Tutor/a', _tutorCtrl, Icons.person),
              _crearCampo('Identificador Escolar', _idEscolarCtrl, Icons.badge),
              
              const SizedBox(height: 25),
              const Text('Credenciales Escolares', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
              const SizedBox(height: 10),
              _crearCampo('Usuario IPASEN', _userIpasenCtrl, Icons.login),
              _crearCampo('Contraseña IPASEN', _passIpasenCtrl, Icons.password),
              _crearCampo('Usuario Cheque Libros', _userLibrosCtrl, Icons.menu_book),
              _crearCampo('Contraseña Cheque Libros', _passLibrosCtrl, Icons.password),
              _crearCampo('Google Classroom', _classroomCtrl, Icons.laptop_chromebook),
              
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: _guardar,
                child: const Text('Guardar Datos', style: TextStyle(fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _crearCampo(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.orange.shade300),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final alumno = widget.persona.rolEstudiante ?? Alumno();
      
      alumno.centroEducativo = _centroCtrl.text;
      alumno.curso = _cursoCtrl.text;
      alumno.identificadorEscolar = _idEscolarCtrl.text;
      alumno.tutor = _tutorCtrl.text;
      alumno.usuarioIpasen = _userIpasenCtrl.text;
      alumno.passIpasen = _passIpasenCtrl.text;
      alumno.usuarioLibros = _userLibrosCtrl.text;
      alumno.passLibros = _passLibrosCtrl.text;
      alumno.conectarConClassroom = _classroomCtrl.text;

      widget.persona.rolEstudiante = alumno;
      
      if (context.mounted) {
        context.read<UsuarioProvider>().notify(personaParaGuardar: widget.persona); // ← Ahora sí guarda en Firestore
        Navigator.pop(context, true);
      }
    }
  }
}
