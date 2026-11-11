class ParteAccidente {
  DateTime fechaHora;
  String lugar;
  String descripcion;
  String matriculaContrario;
  String companiaContrario;
  bool hayHeridos;
  List<String> fotosURLs; // Para guardar las rutas de las fotos del golpe

  ParteAccidente({
    required this.fechaHora,
    required this.lugar,
    required this.descripcion,
    required this.matriculaContrario,
    required this.companiaContrario,
    required this.hayHeridos,
    this.fotosURLs = const [],
  });
}
