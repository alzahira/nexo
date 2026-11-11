import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth? _auth;

  static const String _calendarScope =
      'https://www.googleapis.com/auth/calendar';

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

  User? get user => _user;
  String? get userId => _user?.uid ?? _guestUserId;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null || _guestUserId != null;
  String? get errorMessage => _errorMessage;
  String? get googleAccessToken => _googleAccessToken;

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
      if (kIsWeb) return await _loginConGoogleWeb();

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
            .authenticate(scopeHint: const [_calendarScope]);
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
    final provider = GoogleAuthProvider()..addScope(_calendarScope);
    final UserCredential userCredential =
        await _auth!.signInWithProvider(provider);
    _googleAccessToken = userCredential.credential?.accessToken;
    _user = userCredential.user;
    _guestUserId = null;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Pide (sin interacción si ya se concedió) el token de Google Calendar.
  Future<String?> _tokenCalendarioDe(GoogleSignInAccount account) async {
    try {
      final autorizacion = await account.authorizationClient
              .authorizationForScopes(const [_calendarScope]) ??
          await account.authorizationClient
              .authorizeScopes(const [_calendarScope]);
      return autorizacion.accessToken;
    } catch (e) {
      debugPrint('AuthProvider: sin permiso de Google Calendar: $e');
      return null;
    }
  }

  /// Token de Calendar para el servicio de sincronización.
  Future<String?> obtenerTokenCalendario() async {
    if (_googleAccessToken != null) return _googleAccessToken;
    if (kIsWeb || !_googleSignIn.supportsAuthenticate()) return null;
    try {
      await _inicializarGoogle();
      final account = await _googleSignIn.attemptLightweightAuthentication();
      if (account == null) return null;
      _googleAccessToken = await _tokenCalendarioDe(account);
      return _googleAccessToken;
    } catch (e) {
      debugPrint('AuthProvider: no se pudo obtener el token de Calendar: $e');
      return null;
    }
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
