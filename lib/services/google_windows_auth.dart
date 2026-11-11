// Acceso con Google en escritorio mediante el navegador del sistema.
//
// `google_sign_in` no soporta Windows, así que se usa una página alojada en
// Firebase Hosting que completa el popup de Google y devuelve el token a un
// servidor local efímero. La implementación real solo se compila en plataformas
// con `dart:io`; en web se usa el flujo nativo de Firebase.
export 'google_windows_auth_stub.dart'
    if (dart.library.io) 'google_windows_auth_io.dart';
