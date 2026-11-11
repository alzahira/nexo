import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_home/providers/auth_provider.dart';
import 'package:app_home/providers/usuario_provider.dart';
import 'package:app_home/ui/screens/main_screen.dart';
import 'package:app_home/ui/screens/auth/login_screen.dart';
import 'package:app_home/ui/theme/app_theme.dart';
import 'package:app_home/services/instance_guard.dart' as instance_guard;
import 'firebase_options.dart';

/// En Android/iOS la configuración llega de `google-services.json` /
/// `GoogleService-Info.plist`. En web y escritorio hay que pasarla
/// explícitamente con el archivo generado por `flutterfire configure`.
FirebaseOptions? _firebaseOptions() {
  if (kIsWeb) return DefaultFirebaseOptions.web;
  if (defaultTargetPlatform == TargetPlatform.windows) {
    return DefaultFirebaseOptions.windows;
  }
  return null;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dos instancias no pueden compartir la caché persistente de Firestore:
  // la segunda aborta de forma nativa. Se corta antes de inicializar Firebase.
  if (!await instance_guard.adquirirInstanciaUnica()) {
    runApp(const OtraInstanciaApp());
    return;
  }
  
  try {
    await Firebase.initializeApp(options: _firebaseOptions());
    debugPrint('Firebase inicializado (${Firebase.apps.length} app).');
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint("Firebase not initialized or configuration missing: $e");
  }

  await initializeDateFormatting('es_ES', null);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UsuarioProvider>(
          create: (_) => UsuarioProvider(),
          update: (_, auth, usuario) {
            usuario?.updateUserInfo(auth.userId, auth.user?.email);
            return usuario!;
          },
        ),
      ],
      child: const AppHome(),
    ),
  );
}

/// Aviso que se muestra si ya hay otra copia de AppHome abierta.
class OtraInstanciaApp extends StatelessWidget {
  const OtraInstanciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AppHome',
      theme: AppTheme.dark,
      home: Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.home_rounded, size: 56, color: AppTheme.accent),
              const SizedBox(height: 16),
              Text(
                'AppHome ya está abierto',
                style: AppTheme.dark.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Cierra la otra ventana antes de abrir una nueva copia.',
                style: AppTheme.dark.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: instance_guard.cerrarAplicacion,
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AppHome',
      theme: AppTheme.dark,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    if (authProvider.isLoading) {
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
                ),
                child: const Icon(Icons.home_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: AppTheme.accent),
              const SizedBox(height: 16),
              Text('Cargando AppHome...', style: AppTheme.dark.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return authProvider.isLoggedIn 
        ? const MainScreen() 
        : const LoginScreen();
  }
}

