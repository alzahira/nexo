import 'dart:io';
import 'package:app_home/ui/screens/add_persona_screen.dart';
import 'package:app_home/ui/screens/persona_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/usuarios/persona.dart';
import '../../providers/usuario_provider.dart';
import 'vehiculos_screen.dart';
import 'salud_screen.dart';
import 'educacion_screen.dart';
import 'empleo_screen.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {

  void _mostrarOpciones(BuildContext context, Persona persona, int index) {
    final prov = context.read<UsuarioProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF252838),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              Text('Gestionar a ${persona.nombre}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 15,
                runSpacing: 20,
                children: [
                  _botonCategoria(icon: FontAwesomeIcons.car, color: Colors.blue, label: 'Vehículos',
                    onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => const VehiculosScreen())); }),
                  _botonCategoria(icon: FontAwesomeIcons.stethoscope, color: Colors.red, label: 'Salud',
                    onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => SaludScreen(persona: persona))); }),
                  _botonCategoria(icon: FontAwesomeIcons.userPen, color: Colors.blueGrey, label: 'Ver Perfil',
                    onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => PersonaDetailScreen(persona: persona))); }),
                  _botonCategoria(icon: FontAwesomeIcons.school, color: Colors.orange, label: 'Estudios',
                    onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => EducacionScreen(persona: persona))); }),
                  _botonCategoria(icon: FontAwesomeIcons.briefcase, color: Colors.brown, label: 'Empleo',
                    onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => EmpleoScreen(persona: persona))); }),
                  _botonCategoria(icon: FontAwesomeIcons.trash, color: Colors.red, label: 'Eliminar',
                    onTap: () {
                      Navigator.pop(ctx);
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF2A2D42),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Eliminar miembro', style: TextStyle(color: Colors.white)),
                          content: Text('¿Seguro que quieres eliminar a ${persona.nombre}? Esta acción no se puede deshacer.',
                            style: const TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.white54))),
                            TextButton(
                              onPressed: () { prov.removePersona(index); Navigator.pop(context); },
                              child: const Text('ELIMINAR', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final familia = context.watch<UsuarioProvider>().familia;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Miembros de la Casa'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Configurar Familia Compartida',
            onPressed: () => _mostrarDialogoFamilia(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: familia.length,
        itemBuilder: (context, index) {
          return _tarjetaUsuarioModerno(context, familia[index], index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPersonaScreen()),
          );

          if (result != null && result is Persona) {
            if (context.mounted) {
              context.read<UsuarioProvider>().addPersona(result);
            }
          }
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  ImageProvider? _getFoto(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) {
      return NetworkImage(url);
    }
    // Si es una ruta local (compatibilidad con fotos antiguas no subidas)
    return FileImage(File(url));
  }

  Widget _tarjetaUsuarioModerno(BuildContext context, Persona persona, int index) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.blue.shade400],
          ),
        ),
        child: InkWell(
          onTap: () => _mostrarOpciones(context, persona, index), // ¡Ahora ya existe!
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white24,
                  backgroundImage: _getFoto(persona.fotoUrl),
                  child: persona.fotoUrl == null
                      ? Text(
                          persona.nombre[0],
                          style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  persona.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Grupo: ${persona.grupoSanguineo} | DNI: ${persona.dni}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoFamilia(BuildContext context) {
    final prov = context.read<UsuarioProvider>();
    final ctrl = TextEditingController(text: prov.familyId?.replaceAll('_', '.'));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252838),
        title: const Text('Familia Compartida', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Para ver las viviendas y miembros de otra persona, introduce su email de registro:', 
              style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 15),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email del usuario principal',
                labelStyle: const TextStyle(color: Colors.blueAccent),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blueAccent), borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                prov.setManualFamilyId(ctrl.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sincronizando con nueva familia...')));
              }
            },
            child: const Text('VINCULAR'),
          ),
        ],
      ),
    );
  }

  Widget _botonCategoria({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: FaIcon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
