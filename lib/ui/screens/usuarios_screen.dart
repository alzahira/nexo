import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/usuarios/persona.dart';
import '../../providers/auth_provider.dart';
import '../../providers/usuario_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/foto_perfil_helper.dart';
import 'add_persona_screen.dart';
import 'educacion_screen.dart';
import 'empleo_screen.dart';
import 'persona_detail_screen.dart';
import 'salud_screen.dart';
import 'vehiculos_screen.dart';

/// Pantalla principal de perfil. Muestra directamente el perfil del usuario
/// (o el primero de la familia) y permite cambiar de miembro desde la parte
/// superior, sin tener que entrar en una lista y abrir un menú.
class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  String? _dniSeleccionado;

  // ---------------------------------------------------------------------------
  // Selección de perfil
  // ---------------------------------------------------------------------------

  String _normalizar(String texto) {
    return texto
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }

  /// Intenta averiguar cuál es el perfil del usuario que ha iniciado sesión.
  /// Se apoya en el correo (por ejemplo, javieralzahira@gmail.com → Javier).
  Persona? _perfilPropio(List<Persona> familia) {
    if (familia.isEmpty) return null;

    final email = context.read<AuthProvider>().user?.email;
    if (email != null && email.contains('@')) {
      final local = _normalizar(email.split('@').first);
      for (final persona in familia) {
        final nombre = _normalizar(persona.nombre);
        if (nombre.length >= 3 && local.contains(nombre)) return persona;
      }
    }
    return familia.first;
  }

  Persona? _perfilSeleccionado(List<Persona> familia) {
    if (familia.isEmpty) return null;
    if (_dniSeleccionado != null) {
      for (final persona in familia) {
        if (persona.dni == _dniSeleccionado) return persona;
      }
    }
    return _perfilPropio(familia);
  }

  bool _esPerfilPropio(Persona persona, List<Persona> familia) {
    return _perfilPropio(familia)?.dni == persona.dni;
  }

  void _seleccionar(Persona persona) {
    setState(() => _dniSeleccionado = persona.dni);
  }

  void _volverAMiPerfil(List<Persona> familia) {
    final propio = _perfilPropio(familia);
    if (propio != null) {
      setState(() => _dniSeleccionado = propio.dni);
    }
  }

  // ---------------------------------------------------------------------------
  // Acciones
  // ---------------------------------------------------------------------------

  Future<void> _addPersona() async {
    final result = await Navigator.push<Persona>(
      context,
      MaterialPageRoute(builder: (_) => const AddPersonaScreen()),
    );
    if (result == null || !mounted) return;

    await context.read<UsuarioProvider>().addPersona(result);
    if (!mounted) return;
    setState(() => _dniSeleccionado = result.dni);
  }

  void _abrir(Widget pantalla) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
  }

  Future<void> _editarFoto(Persona persona) {
    return FotoPerfilHelper.cambiar(context, persona);
  }

  void _confirmarEliminar(Persona persona) {
    final prov = context.read<UsuarioProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Eliminar perfil',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          '¿Seguro que quieres eliminar a ${persona.nombre}? '
          'Esta acción no se puede deshacer.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'CANCELAR',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              final index = prov.familia.indexWhere(
                (p) => p.dni == persona.dni,
              );
              Navigator.pop(ctx);
              if (index < 0) return;

              await prov.removePersona(index);
              if (!mounted) return;
              if (_dniSeleccionado == persona.dni) {
                setState(() => _dniSeleccionado = null);
              }
            },
            child: const Text(
              'ELIMINAR',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoFamilia() {
    final prov = context.read<UsuarioProvider>();
    final ctrl = TextEditingController(
      text: prov.familyId?.replaceAll('_', '.'),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text(
          'Familia Compartida',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Para ver las viviendas y miembros de otra persona, '
              'introduce su email de registro:',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Email del usuario principal',
                labelStyle: TextStyle(color: AppTheme.accent),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                prov.setManualFamilyId(ctrl.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sincronizando con nueva familia...'),
                  ),
                );
              }
            },
            child: const Text('VINCULAR'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Utilidades visuales
  // ---------------------------------------------------------------------------

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

  String _edad(Persona persona) {
    final hoy = DateTime.now();
    var edad = hoy.year - persona.fechaNacimiento.year;
    if (hoy.month < persona.fechaNacimiento.month ||
        (hoy.month == persona.fechaNacimiento.month &&
            hoy.day < persona.fechaNacimiento.day)) {
      edad--;
    }
    return '$edad años';
  }

  @override
  Widget build(BuildContext context) {
    final familia = context.watch<UsuarioProvider>().familia;
    final persona = _perfilSeleccionado(familia);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Añadir familiar',
            onPressed: _addPersona,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Configurar Familia Compartida',
            onPressed: _mostrarDialogoFamilia,
          ),
        ],
      ),
      body: persona == null
          ? _estadoVacio()
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  children: [
                    _selectorFamilia(familia, persona),
                    _cabeceraPerfil(persona, familia),
                    const SizedBox(height: 20),
                    _accesosRapidos(persona),
                    const SizedBox(height: 20),
                    _resumenContacto(persona),
                    const SizedBox(height: 20),
                    _gestionFamilia(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _estadoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_add_alt_1_rounded,
              size: 64,
              color: AppTheme.accentLight,
            ),
            const SizedBox(height: 16),
            const Text(
              'Todavía no hay perfiles en tu familia',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Crea el primero para empezar a organizar la casa.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addPersona,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Añadir mi perfil'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Selector de perfiles
  // ---------------------------------------------------------------------------

  Widget _selectorFamilia(List<Persona> familia, Persona actual) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Cambiar de perfil',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: familia.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == familia.length) return _chipAnadir();
              final persona = familia[index];
              return _chipPerfil(
                persona,
                seleccionado: persona.dni == actual.dni,
                onTap: () => _seleccionar(persona),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _chipPerfil(
    Persona persona, {
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 78,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado ? AppTheme.softMint : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: seleccionado ? AppTheme.accent : AppTheme.borderColor,
            width: seleccionado ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.accent.withValues(alpha: 0.16),
              backgroundImage: _getFoto(persona.fotoUrl),
              child: persona.fotoUrl == null || persona.fotoUrl!.isEmpty
                  ? Text(
                      persona.nombre.isNotEmpty
                          ? persona.nombre[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accentGlow,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              persona.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: seleccionado ? FontWeight.w800 : FontWeight.w600,
                color: seleccionado
                    ? AppTheme.accentGlow
                    : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipAnadir() {
    return GestureDetector(
      onTap: _addPersona,
      child: Container(
        width: 78,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.softMint,
              child: Icon(Icons.add_rounded, color: AppTheme.accent),
            ),
            SizedBox(height: 6),
            Text(
              'Añadir',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cabecera del perfil
  // ---------------------------------------------------------------------------

  Widget _cabeceraPerfil(Persona persona, List<Persona> familia) {
    final propio = _esPerfilPropio(persona, familia);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.mintGradient,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor:
                        AppTheme.accent.withValues(alpha: 0.16),
                    backgroundImage: _getFoto(persona.fotoUrl),
                    child: persona.fotoUrl == null || persona.fotoUrl!.isEmpty
                        ? Text(
                            persona.nombre.isNotEmpty
                                ? persona.nombre[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accentGlow,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _editarFoto(persona),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.bgCard, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          '${persona.nombre} ${persona.apellidos}'.trim(),
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (propio)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Tú',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'DNI ${persona.dni}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _miniChip(
                          Icons.cake_outlined,
                          _edad(persona),
                        ),
                        _miniChip(
                          Icons.bloodtype_outlined,
                          'Grupo ${persona.grupoSanguineo}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppTheme.textSecondary,
                ),
                tooltip: 'Opciones del perfil',
                onSelected: (value) {
                  if (value == 'editar') {
                    _abrir(PersonaDetailScreen(persona: persona));
                  } else if (value == 'eliminar') {
                    _confirmarEliminar(persona);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'editar',
                    child: Text('Editar ficha'),
                  ),
                  PopupMenuItem(
                    value: 'eliminar',
                    child: Text(
                      'Eliminar perfil',
                      style: TextStyle(color: AppTheme.dangerRed),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!propio) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _volverAMiPerfil(familia),
                icon: const Icon(Icons.person_rounded, size: 17),
                label: const Text('Volver a mi perfil'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniChip(IconData icono, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.bgCard.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: AppTheme.accentGlow),
          const SizedBox(width: 4),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Accesos directos
  // ---------------------------------------------------------------------------

  Widget _accesosRapidos(Persona persona) {
    final accesos = <_Acceso>[
      _Acceso(
        titulo: 'Salud',
        subtitulo: 'Citas y vacunas',
        icono: FontAwesomeIcons.stethoscope,
        color: Colors.red,
        onTap: () => _abrir(SaludScreen(persona: persona)),
      ),
      _Acceso(
        titulo: 'Estudios',
        subtitulo: 'Cursos y pagos',
        icono: FontAwesomeIcons.school,
        color: Colors.orange,
        onTap: () => _abrir(EducacionScreen(persona: persona)),
      ),
      _Acceso(
        titulo: 'Empleo',
        subtitulo: 'Nóminas y contratos',
        icono: FontAwesomeIcons.briefcase,
        color: Colors.brown,
        onTap: () => _abrir(EmpleoScreen(persona: persona)),
      ),
      _Acceso(
        titulo: 'Vehículos',
        subtitulo: 'ITV y seguro',
        icono: FontAwesomeIcons.carSide,
        color: Colors.blue,
        onTap: () => _abrir(const VehiculosScreen()),
      ),
      _Acceso(
        titulo: 'Documentos',
        subtitulo: 'DNI y tallas',
        icono: FontAwesomeIcons.idCard,
        color: Colors.blueGrey,
        onTap: () => _abrir(PersonaDetailScreen(persona: persona)),
      ),
      _Acceso(
        titulo: 'Ficha completa',
        subtitulo: 'Datos y contacto',
        icono: FontAwesomeIcons.userPen,
        color: AppTheme.accent,
        onTap: () => _abrir(PersonaDetailScreen(persona: persona)),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Accesos rápidos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final columnas = constraints.maxWidth >= 720 ? 3 : 2;
            final ancho =
                (constraints.maxWidth - spacing * (columnas - 1)) / columnas;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: accesos
                  .map(
                    (acceso) => SizedBox(
                      width: ancho,
                      height: 112,
                      child: _tarjetaAcceso(acceso),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _tarjetaAcceso(_Acceso acceso) {
    return Material(
      color: AppTheme.bgCard,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: acceso.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: acceso.color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: FaIcon(
                    acceso.icono,
                    color: acceso.color,
                    size: 17,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                acceso.titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                acceso.subtitulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Datos de contacto y gestión
  // ---------------------------------------------------------------------------

  Widget _resumenContacto(Persona persona) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          _filaContacto(
            Icons.phone_rounded,
            'Teléfono',
            persona.telefono.isEmpty ? 'Sin datos' : persona.telefono,
            Colors.green,
          ),
          const Divider(height: 18),
          _filaContacto(
            Icons.location_on_rounded,
            'Dirección',
            persona.direccion.isEmpty ? 'Sin datos' : persona.direccion,
            AppTheme.accent,
          ),
        ],
      ),
    );
  }

  Widget _filaContacto(
    IconData icono,
    String etiqueta,
    String valor,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icono, size: 17, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                valor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _gestionFamilia() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.softSand,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Familia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Añade a los miembros de tu casa o comparte los datos con otra cuenta.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: _addPersona,
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Añadir familiar'),
              ),
              OutlinedButton.icon(
                onPressed: _mostrarDialogoFamilia,
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text('Compartir familia'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Acceso {
  final String titulo;
  final String subtitulo;
  final FaIconData icono;
  final Color color;
  final VoidCallback onTap;

  const _Acceso({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.color,
    required this.onTap,
  });
}
