class Habitacion {
  String nombre;
  String tipo;
  DateTime? ultimaVezPintado;
  String? colorPared;
  String? notasMantenimiento;

  Habitacion({
    required this.nombre,
    required this.tipo,
    this.ultimaVezPintado,
    this.colorPared,
    this.notasMantenimiento,
  });

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'tipo': tipo,
        'ultimaVezPintado': ultimaVezPintado?.toIso8601String(),
        'colorPared': colorPared,
        'notasMantenimiento': notasMantenimiento,
      };

  static Habitacion fromMap(Map<String, dynamic> map) => Habitacion(
        nombre: map['nombre'] ?? '',
        tipo: map['tipo'] ?? '',
        ultimaVezPintado: map['ultimaVezPintado'] != null
            ? DateTime.parse(map['ultimaVezPintado'])
            : null,
        colorPared: map['colorPared'],
        notasMantenimiento: map['notasMantenimiento'],
      );
}
