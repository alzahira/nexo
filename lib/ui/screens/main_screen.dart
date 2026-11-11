import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/common/app_event.dart';
import '../../providers/calendar_sync_provider.dart';
import '../../providers/usuario_provider.dart';
import '../theme/app_theme.dart';
import 'usuarios_screen.dart';
import 'hogar_screen.dart';
import 'gestion_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0; // Inicio (calendario) al abrir la app
  late final UsuarioProvider _usuario;
  late final CalendarSyncProvider _calendar;
  Timer? _debounce;
  String _firmaEventos = '';

  final List<Widget> _screens = [
    const HomeScreen(),
    const UsuariosScreen(),
    const HogarScreen(),
    const GestionScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _usuario = context.read<UsuarioProvider>();
    _calendar = context.read<CalendarSyncProvider>();
    _usuario.addListener(_alCambiarDatos);
    _firmaEventos = _firma(_usuario.todosLosEventos);
    _programarSync(const Duration(seconds: 1));
  }

  String _firma(List<AppEvent> eventos) {
    final items = eventos.map((e) {
      final d = e.fecha.toLocal();
      return '${e.titulo.trim().toLowerCase()}|${d.year}-${d.month}-${d.day}';
    }).toList()
      ..sort();
    return items.join(';');
  }

  void _alCambiarDatos() {
    final nueva = _firma(_usuario.todosLosEventos);
    if (nueva == _firmaEventos) return;
    _firmaEventos = nueva;
    _programarSync(const Duration(seconds: 2));
  }

  void _programarSync(Duration espera) {
    _debounce?.cancel();
    _debounce = Timer(espera, () {
      if (!mounted) return;
      unawaited(_calendar.sincronizar(
        eventosLocales: _usuario.todosLosEventos,
        silencioso: true,
      ));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _programarSync(const Duration(seconds: 1));
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _usuario.removeListener(_alCambiarDatos);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = context.watch<UsuarioProvider>();

    if (usuarioProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppTheme.glowShadow,
                ),
                child: const Icon(Icons.home_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: AppTheme.accent),
              const SizedBox(height: 12),
              const Text('Cargando desde la nube...', style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          border: const Border(top: BorderSide(color: AppTheme.borderColor, width: 1)),
          boxShadow: [
            BoxShadow(color: const Color(0xFF2E3A34).withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppTheme.accent,
          unselectedItemColor: AppTheme.textSecondary,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Inicio'),
            BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.user, size: 20), label: 'Mi perfil'),
            BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.houseChimney, size: 20), label: 'Hogar'),
            BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.basketShopping, size: 20), label: 'Gestión'),
          ],
        ),
      ),
    );
  }
}
