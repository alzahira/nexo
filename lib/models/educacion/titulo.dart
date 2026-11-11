class Titulo {
  String nombreTitulo;
  String institucion;
  DateTime fechaExpedicion;
  String calificacionHonor;
  String? archivoURL;

  Titulo({
    required this.nombreTitulo,
    required this.institucion,
    required this.fechaExpedicion,
    this.calificacionHonor = '',
    this.archivoURL,
  });

  Map<String, dynamic> toMap() => {
        'nombreTitulo': nombreTitulo,
        'institucion': institucion,
        'fechaExpedicion': fechaExpedicion.toIso8601String(),
        'calificacionHonor': calificacionHonor,
        'archivoURL': archivoURL,
      };

  static Titulo fromMap(Map<String, dynamic> map) => Titulo(
        nombreTitulo: map['nombreTitulo'] ?? '',
        institucion: map['institucion'] ?? '',
        fechaExpedicion: DateTime.parse(map['fechaExpedicion']),
        calificacionHonor: map['calificacionHonor'] ?? '',
        archivoURL: map['archivoURL'],
      );
}
