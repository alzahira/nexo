import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
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

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const UsuariosScreen(),
    const HogarScreen(),
    const GestionScreen(),
  ];

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
            BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, -5)),
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
            BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.users, size: 20), label: 'Familia'),
            BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.houseChimney, size: 20), label: 'Hogar'),
            BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.basketShopping, size: 20), label: 'Gestión'),
          ],
        ),
      ),
    );
  }
}
