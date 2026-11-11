/// Implementación de respaldo para plataformas sin `dart:io` (web).
class GoogleWindowsAuth {
  static Future<Map<String, String>> signIn({String? email}) async {
    throw UnsupportedError(
      'El acceso con Google de escritorio no está disponible en esta plataforma.',
    );
  }
}
