import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart' as app_auth;
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _verContrasena = false;
  bool _modoRegistro = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarFormulario() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<app_auth.AuthProvider>();
    bool ok = _modoRegistro
        ? await auth.registrarConEmail(_emailCtrl.text.trim(), _passCtrl.text)
        : await auth.loginConEmail(_emailCtrl.text.trim(), _passCtrl.text);
    if (!ok && mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.errorMessage!),
        backgroundColor: AppTheme.dangerRed,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _loginGoogle() async {
    final auth = context.read<app_auth.AuthProvider>();
    final ok = await auth.loginConGoogle();
    if (!ok && mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.errorMessage!),
        backgroundColor: AppTheme.dangerRed,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // Efecto de círculos de neón en el fondo
          Positioned(top: -80, left: -80, child: _glowCircle(200, AppTheme.accent.withValues(alpha: 0.15))),
          Positioned(bottom: -100, right: -60, child: _glowCircle(280, AppTheme.accentLight.withValues(alpha: 0.1))),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      // Logo
                      Image.asset(
                        'assets/icons/logo.png',
                        width: 96,
                        height: 96,
                        filterQuality: FilterQuality.high,
                      ),
                      const SizedBox(height: 12),
                      const Text('Nexo',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      Text(
                        _modoRegistro ? 'Crea tu cuenta familiar' : 'Bienvenido de vuelta',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                      ),
                      const SizedBox(height: 36),

                      if (!auth.firebaseAvailable) ...[
                        _avisoSinFirebase(),
                        const SizedBox(height: 16),
                      ],

                      // Tarjeta glassmorphism
                      Container(
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppTheme.borderColor),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: AppTheme.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.accent),
                                ),
                                validator: (v) => v == null || !v.contains('@') ? 'Email no válido' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: !_verContrasena,
                                style: const TextStyle(color: AppTheme.textPrimary),
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                                  prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.accent),
                                  suffixIcon: IconButton(
                                    icon: Icon(_verContrasena ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary),
                                    onPressed: () => setState(() => _verContrasena = !_verContrasena),
                                  ),
                                ),
                                validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                              ),
                              const SizedBox(height: 28),

                              // Botón email
                              Container(
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: AppTheme.glowShadow,
                                ),
                                child: ElevatedButton(
                                  onPressed: auth.isLoading ? null : _enviarFormulario,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: auth.isLoading
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : Text(_modoRegistro ? 'Crear Cuenta' : 'Iniciar Sesión',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                              const SizedBox(height: 20),

                              Row(children: [
                                const Expanded(child: Divider(color: AppTheme.borderColor)),
                                const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('o', style: TextStyle(color: AppTheme.textSecondary))),
                                const Expanded(child: Divider(color: AppTheme.borderColor)),
                              ]),
                              const SizedBox(height: 16),

                              // Botón Google (móvil/web nativo y Windows por navegador)
                              if (kIsWeb ||
                                  defaultTargetPlatform == TargetPlatform.android ||
                                  defaultTargetPlatform == TargetPlatform.iOS ||
                                  defaultTargetPlatform == TargetPlatform.windows) ...[
                                OutlinedButton.icon(
                                  onPressed: auth.isLoading ? null : _loginGoogle,
                                  icon: const Icon(Icons.g_mobiledata, size: 28, color: Color(0xFF4285F4)),
                                  label: const Text('Continuar con Google',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    side: const BorderSide(color: AppTheme.borderColor),
                                  ),
                                ),
                                if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Se abrirá tu navegador para elegir la cuenta de Google.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                    ),
                                  ),
                                const SizedBox(height: 18),
                              ],

                              TextButton(
                                onPressed: () => setState(() => _modoRegistro = !_modoRegistro),
                                child: Text(
                                  _modoRegistro ? '¿Ya tienes cuenta? Inicia sesión' : '¿Sin cuenta? Regístrate gratis',
                                  style: const TextStyle(color: AppTheme.accentGlow, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const Divider(color: AppTheme.borderColor),
                              TextButton(
                                onPressed: auth.entrarComoInvitado,
                                child: const Text('Entrar como Invitado', style: TextStyle(color: AppTheme.textSecondary)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avisoSinFirebase() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.dangerRed.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.dangerRed.withValues(alpha: 0.5)),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.warning_amber_rounded, color: AppTheme.dangerRed, size: 22),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Firebase no está configurado: el login y los datos no funcionarán. '
            'Añade google-services.json o ejecuta "flutterfire configure".',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 12.5, height: 1.35),
          ),
        ),
      ],
    ),
  );

  Widget _glowCircle(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color,
      boxShadow: [BoxShadow(color: color, blurRadius: 60, spreadRadius: 20)]),
  );
}
