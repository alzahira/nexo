class AvisoSalud {
  String titulo;
  String prioridad;
  String descripcion;
  DateTime fechaAviso;

  AvisoSalud({
    required this.titulo,
    this.prioridad = 'Media',
    this.descripcion = '',
    required this.fechaAviso,
  });

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'prioridad': prioridad,
        'descripcion': descripcion,
        'fechaAviso': fechaAviso.toIso8601String(),
      };

  static AvisoSalud fromMap(Map<String, dynamic> map) => AvisoSalud(
        titulo: map['titulo'] ?? '',
        prioridad: map['prioridad'] ?? 'Media',
        descripcion: map['descripcion'] ?? '',
        fechaAviso: DateTime.parse(map['fechaAviso']),
      );
}
