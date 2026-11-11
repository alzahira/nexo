import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth? _auth;
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar',
    ],
  );

  /// Mensaje único para cuando la app arranca sin configuración de Firebase.
  static const String mensajeSinFirebase =
      'Firebase no está configurado en esta instalación. '
      'Añade android/app/google-services.json o ejecuta "flutterfire configure".';

  User? _user;
  String? _guestUserId; // ID para el modo invitado
  bool _isLoading = false;
  String? _errorMessage;
  String? _googleAccessToken; // Token para Google Calendar API

  User? get user => _user;
  String? get userId => _user?.uid ?? _guestUserId;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null || _guestUserId != null;
  String? get errorMessage => _errorMessage;
  String? get googleAccessToken => _googleAccessToken;
  GoogleSignIn get googleSignIn => _googleSignIn;

  /// `false` cuando no hay configuración de Firebase disponible
  /// (falta google-services.json / firebase_options.dart).
  bool get firebaseAvailable => _auth != null;

  // --- Modo Invitado ---
  void entrarComoInvitado() {
    _user = null;
    _guestUserId = "usuario_invitado";
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  AuthProvider() {
    _init();
  }

  void _init() {
    try {
      if (Firebase.apps.isEmpty) {
        debugPrint("AuthProvider: Firebase apps is empty, skipping initialization.");
        return;
      }
      _auth = FirebaseAuth.instance;
      // Escuchar cambios de estado de autenticación
      _auth?.authStateChanges().listen((User? user) {
        _user = user;
        notifyListeners();
      });
    } catch (e) {
      debugPrint("AuthProvider: Firebase not available: $e");
    }
  }

  // --- Login con Email y Contraseña ---
  Future<bool> loginConEmail(String email, String contrasena) async {
    if (_auth == null) return _falloSinFirebase();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final credencial = await _auth!
          .signInWithEmailAndPassword(email: email, password: contrasena);
      _user = credencial.user;
      _guestUserId = null;
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _traducirError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudo iniciar sesión. Revisa tu conexión e inténtalo de nuevo.';
      notifyListeners();
      return false;
    }
  }

  // --- Registro con Email y Contraseña ---
  Future<bool> registrarConEmail(String email, String contrasena) async {
    if (_auth == null) return _falloSinFirebase();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final credencial = await _auth!
          .createUserWithEmailAndPassword(email: email, password: contrasena);
      _user = credencial.user;
      _guestUserId = null;
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _traducirError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudo crear la cuenta. Revisa tu conexión e inténtalo de nuevo.';
      notifyListeners();
      return false;
    }
  }

  /// Deja constancia del problema y devuelve `false` para que la UI lo muestre.
  bool _falloSinFirebase() {
    _isLoading = false;
    _errorMessage = mensajeSinFirebase;
    notifyListeners();
    return false;
  }

  // --- Login con Google (sirve también para Google Calendar) ---
  Future<bool> loginConGoogle() async {
    if (_auth == null) return _falloSinFirebase();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false; 
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      _googleAccessToken = googleAuth.accessToken;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth!.signInWithCredential(credential);
      _user = userCredential.user;
      _guestUserId = null;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _traducirError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al conectar con Google. Inténtalo de nuevo.';
      notifyListeners();
      return false;
    }
  }

  // --- Cerrar Sesión ---
  Future<void> cerrarSesion() async {
    // google_sign_in no existe en Windows/Linux/macOS: solo móvil y web.
    final googleDisponible = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    if (googleDisponible) {
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        debugPrint('AuthProvider: no se pudo cerrar sesión de Google: $e');
      }
    }
    try {
      await _auth?.signOut();
    } catch (e) {
      debugPrint('AuthProvider: no se pudo cerrar sesión de Firebase: $e');
    }
    _googleAccessToken = null;
    _user = null;
    _guestUserId = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // --- Traducción de errores de Firebase Auth ---
  String _traducirError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe ninguna cuenta con ese email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese email.';
      case 'weak-password':
        return 'La contraseña es demasiado débil (mínimo 6 caracteres).';
      case 'invalid-email':
        return 'El formato del email no es válido.';
      case 'user-disabled':
        return 'Esta cuenta está deshabilitada. Contacta con el administrador.';
      case 'missing-password':
        return 'Escribe una contraseña.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Espera un momento.';
      case 'operation-not-allowed':
        return 'El acceso con email y contraseña está desactivado en Firebase. '
            'Actívalo en Authentication → Sign-in method.';
      case 'network-request-failed':
        return 'No se pudo conectar con Firebase. Revisa tu conexión.';
      default:
        return 'Error de autenticación: $code';
    }
  }
}
