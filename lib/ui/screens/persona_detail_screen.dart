import 'package:app_home/models/usuarios/documento_identidad.dart';
import 'package:app_home/models/usuarios/ficha_tallas.dart';
import 'package:app_home/ui/screens/add_documento_screen.dart';
import 'package:app_home/ui/screens/edit_tallas_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../widgets/app_icon.dart';
import '../widgets/foto_perfil_helper.dart';
import '../theme/app_theme.dart';
import 'dart:convert';
import 'dart:io';
import '../../models/usuarios/persona.dart';
import '../../providers/usuario_provider.dart';
import 'package:intl/intl.dart';

class PersonaDetailScreen extends StatelessWidget {
  final Persona persona;

  const PersonaDetailScreen({super.key, required this.persona});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de ${persona.nombre}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () => _mostrarMenuEdicion(context),
          ),
        ],
      ),
      body: Consumer<UsuarioProvider>(
        builder: (context, prov, _) {
          // Si la foto se acaba de guardar, el provider trae una copia nueva
          // de la persona y la pantalla se refresca sin salir del perfil.
          final persona = prov.familia.firstWhere(
            (p) => p.dni == this.persona.dni,
            orElse: () => this.persona,
          );
          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. CABECERA CON FOTO
                _cabeceraPerfil(context, persona),

            // 2. DATOS PERSONALES (DNI, Nacimiento, Sangre)
            _seccionTitulo('Datos Personales'),
            _infoTile(FontAwesomeIcons.idCard, 'DNI', persona.dni),
            _infoTile(
              FontAwesomeIcons.cakeCandles,
              'Fecha de Nacimiento',
              DateFormat('dd/MM/yyyy').format(persona.fechaNacimiento),
              onTap: () => _editarFechaNacimiento(context, persona),
              trailing: const Icon(
                Icons.edit_calendar_rounded,
                size: 18,
                color: AppTheme.textSecondary,
              ),
            ),
            _infoTile(
              FontAwesomeIcons.droplet,
              'Grupo Sanguíneo',
              persona.grupoSanguineo,
              color: Colors.red,
            ),

            const Divider(),

            // 3. CONTACTO Y DIRECCIÓN
            _seccionTitulo('Contacto'),
            _infoTile(
              FontAwesomeIcons.phone,
              'Teléfono',
              persona.telefono,
              color: Colors.green,
            ),
            _infoTile(
              FontAwesomeIcons.locationDot,
              'Dirección',
              persona.direccion,
            ),

            const SizedBox(height: 30),

            // --- SECCIÓN DE DOCUMENTOS ---
            _seccionTitulo('Documentos de Identidad'),
            if (persona.documentos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'No hay documentos registrados',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              )
            else
              ...persona.documentos.map(
                (doc) => ExpansionTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.fileContract,
                    color: Colors.blue,
                  ),
                  title: Text(doc.tipoDocumento),
                  subtitle: Text(
                    'Expira: ${DateFormat('dd/MM/yyyy').format(doc.fechaCaducidad)}',
                  ),
                  children: [
                    _infoTile(Icons.numbers, 'Número', doc.numero),
                    _infoTile(
                      Icons.calendar_today,
                      'Expedición',
                      DateFormat('dd/MM/yyyy').format(doc.fechaExpedicion),
                    ),
                  ],
                ),
              ),

            const Divider(),

            // --- SECCIÓN DE TALLAS ---
            _seccionTitulo('Ficha de Tallas'),
            if (persona.tallas != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  // Wrap para que los iconos se ajusten al ancho
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _tallaWidget(
                      FontAwesomeIcons.shirt,
                      'Camisa',
                      persona.tallas!.tallaCamisa,
                    ),
                    _tallaWidget(
                      FontAwesomeIcons.socks,
                      'Pantalón',
                      persona.tallas!.tallaPantalon,
                    ),
                    _tallaWidget(
                      FontAwesomeIcons.shoePrints,
                      'Calzado',
                      persona.tallas!.tallaCalzado.toString(),
                    ),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Ficha de tallas no configurada',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cabeceraPerfil(BuildContext context, Persona persona) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        gradient: AppTheme.mintGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        border: const Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 65,
                backgroundColor: AppTheme.accent.withValues(alpha: 0.16),
                backgroundImage: _getFoto(persona.fotoUrl),
                child: persona.fotoUrl == null
                    ? const Icon(Icons.person, size: 65, color: AppTheme.accentGlow)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => FotoPerfilHelper.cambiar(context, persona),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.bgCard, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            '${persona.nombre} ${persona.apellidos}'.trim(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'DNI ${persona.dni}',
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getFoto(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('data:image')) {
      try {
        return MemoryImage(base64Decode(url.substring(url.indexOf(',') + 1)));
      } catch (_) {
        return null;
      }
    }
    if (url.startsWith('http')) return NetworkImage(url);
    return FileImage(File(url));
  }

  Future<void> _editarFechaNacimiento(
    BuildContext context,
    Persona persona,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: persona.fechaNacimiento,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked == null || !context.mounted) return;

    persona.fechaNacimiento = picked;
    await context.read<UsuarioProvider>().notify(
      personaParaGuardar: persona,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fecha de nacimiento actualizada')),
      );
    }
  }

  Widget _seccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          titulo,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _infoTile(
    Object icon,
    String label,
    String value, {
    Color color = AppTheme.accent,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      trailing: trailing,
      leading: AppIcon(icon, color: color, size: 20),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _tallaWidget(FaIconData icon, String label, String valor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, color: AppTheme.accentGlow, size: 24),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      ],
    );
  }

  void _mostrarMenuEdicion(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '¿Qué quieres actualizar?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.straighten, color: Colors.blueGrey),
              title: const Text('Ficha de Tallas'),
              onTap: () {
                Navigator.pop(context);
                // Aquí navegaremos a la pantalla de editar tallas
                _irAEditarTallas(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.badge_outlined, color: Colors.blue),
              title: const Text('Añadir Documento'),
              onTap: () {
                Navigator.pop(context); // Cierra el menú inferior
                _irAAnadirDocumento(
                  context,
                ); // <--- AHORA SÍ LLAMA A LA FUNCIÓN
              },
            ),
          
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Future<void> _irAEditarTallas(BuildContext context) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTallasScreen(tallasActuales: persona.tallas)),
    );

    if (resultado != null && resultado is FichaTallas && context.mounted) {
      persona.tallas = resultado;
      context.read<UsuarioProvider>().notify(personaParaGuardar: persona); // Guardar en Firestore
    }
  }

  Future<void> _irAAnadirDocumento(BuildContext context) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDocumentoScreen()),
    );

    if (resultado != null && resultado is DocumentoIdentidad && context.mounted) {
      persona.documentos.add(resultado);
      context.read<UsuarioProvider>().notify(personaParaGuardar: persona); // Guardar en Firestore
    }
  }
}
