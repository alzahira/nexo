import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/google_windows_auth.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth? _auth;

  static const String _calendarScope =
      'https://www.googleapis.com/auth/calendar';
  static const String _tasksScope = 'https://www.googleapis.com/auth/tasks';

  /// Permisos que se piden al conectar Google: calendario y tareas (la lista
  /// de la compra se sincroniza con una lista de Google Tasks).
  static const List<String> _googleScopes = [_calendarScope, _tasksScope];

  /// Cliente OAuth de tipo "web" del proyecto app-home-familia.
  /// Google Sign-In en Android lo necesita para emitir el idToken.
  static const String _googleServerClientId =
      '1031214812224-1flu4j9p9us6iqfoso872t1dr9bs48ck.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInicializado = false;

  Future<void> _inicializarGoogle() async {
    if (_googleInicializado) return;
    await _googleSignIn.initialize(serverClientId: _googleServerClientId);
    _googleInicializado = true;
  }

  /// Mensaje único para cuando la app arranca sin configuración de Firebase.
  static const String mensajeSinFirebase =
      'Firebase no está configurado en esta instalación. '
      'Añade android/app/google-services.json o ejecuta "flutterfire configure".';

  User? _user;
  String? _guestUserId; // ID para el modo invitado
  bool _isLoading = false;
  String? _errorMessage;
  String? _googleAccessToken; // Token para Google Calendar API
  String? _calendarError; // Motivo por el que Calendar no está conectado
  String? _calendarEmail; // Cuenta de Google usada para el calendario

  User? get user => _user;
  String? get userId => _user?.uid ?? _guestUserId;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null || _guestUserId != null;
  String? get errorMessage => _errorMessage;
  String? get googleAccessToken => _googleAccessToken;

  /// Explica por qué no se pudo conectar Google Calendar (null si todo bien).
  String? get calendarError => _calendarError;

  /// Correo de la cuenta de Google que dio permiso al calendario.
  String? get calendarEmail => _calendarEmail;

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
    _calendarError = null;
    notifyListeners();
    try {
      if (kIsWeb) return await _loginConGoogleWeb();

      // Windows no tiene implementación de google_sign_in: se usa el navegador
      // del sistema con una página alojada en Firebase Hosting.
      if (defaultTargetPlatform == TargetPlatform.windows) {
        return await _loginConGoogleWindows();
      }

      if (!_googleSignIn.supportsAuthenticate()) {
        _isLoading = false;
        _errorMessage =
            'El acceso con Google no está disponible en esta plataforma.';
        notifyListeners();
        return false;
      }

      await _inicializarGoogle();

      final GoogleSignInAccount googleUser;
      try {
        googleUser = await _googleSignIn
            .authenticate(scopeHint: _googleScopes);
      } on GoogleSignInException catch (e) {
        _isLoading = false;
        if (e.code != GoogleSignInExceptionCode.canceled) {
          _errorMessage = 'No se pudo completar el acceso con Google.';
          debugPrint('AuthProvider: GoogleSignInException ${e.code}: $e');
        }
        notifyListeners();
        return false;
      }

      final String? idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        _isLoading = false;
        _errorMessage =
            'Google no devolvió un token válido. Revisa la configuración de Firebase.';
        notifyListeners();
        return false;
      }

      _googleAccessToken = await _tokenCalendarioDe(googleUser);

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: _googleAccessToken,
      );

      final UserCredential userCredential =
          await _auth!.signInWithCredential(credential);
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
      debugPrint('AuthProvider: error en loginConGoogle: $e');
      notifyListeners();
      return false;
    }
  }

  /// En web google_sign_in 7 no permite autenticar con un botón propio,
  /// así que se usa el popup nativo de Firebase.
  Future<bool> _loginConGoogleWeb() async {
    final provider = GoogleAuthProvider()..addScope(_calendarScope)..addScope(_tasksScope);
    final UserCredential userCredential =
        await _auth!.signInWithProvider(provider);
    _googleAccessToken = userCredential.credential?.accessToken;
    _user = userCredential.user;
    _guestUserId = null;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Google en Windows: navegador del sistema + servidor local para el token.
  Future<bool> _loginConGoogleWindows() async {
    try {
      final tokens = await GoogleWindowsAuth.signIn(email: _user?.email);
      final accessToken = tokens['accessToken'] ?? '';
      final idToken = tokens['idToken'] ?? '';

      // Evita cambiar de cuenta sin querer: el puente deja elegir cualquier
      // cuenta de Google, pero la familia vive en la cuenta con la que se
      // entró. Si no coinciden, se aborta antes de tocar la sesión.
      final correoToken = _correoDelIdToken(idToken);
      final correoApp = (_user?.email ?? '').trim().toLowerCase();
      if (correoToken != null &&
          correoApp.isNotEmpty &&
          correoToken != correoApp) {
        _isLoading = false;
        _errorMessage = 'Has elegido la cuenta $correoToken, pero Nexo está '
            'abierta con $correoApp. Usa la misma cuenta de Google.';
        notifyListeners();
        return false;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken.isEmpty ? null : accessToken,
      );
      final userCredential = await _auth!.signInWithCredential(credential);
      _googleAccessToken = accessToken.isEmpty ? null : accessToken;
      _calendarEmail = correoToken ?? correoApp;
      _calendarError = _googleAccessToken == null
          ? 'Google no devolvió permiso para el calendario.'
          : null;
      _user = userCredential.user;
      _guestUserId = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AuthProvider: error en Google Windows: $e');
      _isLoading = false;
      _errorMessage = e is StateError
          ? e.message
          : 'No se pudo completar el acceso con Google. Inténtalo de nuevo.';
      notifyListeners();
      return false;
    }
  }

  /// Correo del `idToken` de Google (JWT sin firmar verificar: solo se usa
  /// para comparar con la cuenta de la app, no para autorizar).
  String? _correoDelIdToken(String idToken) {
    try {
      final partes = idToken.split('.');
      if (partes.length < 2) return null;
      var payload = partes[1].replaceAll('-', '+').replaceAll('_', '/');
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      final json = utf8.decode(base64.decode(payload));
      final datos = jsonDecode(json) as Map<String, dynamic>;
      return (datos['email'] as String?)?.trim().toLowerCase();
    } catch (_) {
      return null;
    }
  }

  /// Pide (sin interacción si ya se concedió) el token de Google Calendar.
  Future<String?> _tokenCalendarioDe(GoogleSignInAccount account) async {
    _calendarEmail = account.email.trim().toLowerCase();
    try {
      final autorizacion = await account.authorizationClient
              .authorizationForScopes(_googleScopes) ??
          await account.authorizationClient
              .authorizeScopes(_googleScopes);
      final token = autorizacion.accessToken;
      if (token.isEmpty) {
        _calendarError =
            'Google no devolvió permiso para el calendario de ${account.email}.';
        return null;
      }
      _calendarError = null;
      return token;
    } catch (e) {
      debugPrint('AuthProvider: sin permiso de Google Calendar: $e');
      _calendarError =
          'Google no dio permiso para el calendario. Puede que la cuenta '
          '${account.email} no lo haya aceptado: $e';
      return null;
    }
  }

  /// Token de Calendar para el servicio de sincronización.
  Future<String?> obtenerTokenCalendario() async {
    if (kIsWeb) return _googleAccessToken;

    // google_sign_in no implementa Windows/Linux/macOS: allí el token solo
    // existe tras el puente de Google y no se puede renovar sin volver a
    // conectar la cuenta. Evitamos llamar a supportsAuthenticate() en esas
    // plataformas porque lanza UnimplementedError.
    final esMovil = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    if (esMovil && _googleSignIn.supportsAuthenticate()) {
      try {
        await _inicializarGoogle();
        // Intento silencioso: si el usuario ya dio permiso antes, devuelve el
        // token sin abrir ninguna ventana (y renueva el de la hora anterior).
        final account = await _googleSignIn.attemptLightweightAuthentication();
        if (account != null) {
          final token = await _tokenCalendarioDe(account);
          if (token != null && token.isNotEmpty) {
            _googleAccessToken = token;
            return token;
          }
        }
      } catch (e) {
        debugPrint('AuthProvider: no se pudo renovar el token: $e');
      }
    }

    if (_googleAccessToken != null && _googleAccessToken!.isNotEmpty) {
      return _googleAccessToken;
    }
    _calendarError ??=
        'Pulsa Conectar y acepta el permiso de Google Calendar.';
    return null;
  }

  // --- Cerrar Sesión ---
  Future<void> cerrarSesion() async {
    // google_sign_in solo se inicializa en móvil (en web se usa el popup de Firebase).
    final googleDisponible = !kIsWeb &&
        _googleInicializado &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
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
    _calendarError = null;
    _calendarEmail = null;
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
