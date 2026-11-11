class Tarea {
  String titulo;
  DateTime fechaEntrega;
  String descripcion;
  bool entregado;

  Tarea({
    required this.titulo,
    required this.fechaEntrega,
    this.descripcion = '',
    this.entregado = false,
  });

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'fechaEntrega': fechaEntrega.toIso8601String(),
        'descripcion': descripcion,
        'entregado': entregado,
      };

  static Tarea fromMap(Map<String, dynamic> map) => Tarea(
        titulo: map['titulo'] ?? '',
        fechaEntrega: DateTime.parse(map['fechaEntrega']),
        descripcion: map['descripcion'] ?? '',
        entregado: map['entregado'] ?? false,
      );
}
