class Suscripcion {
  String nombre;
  double precio;
  String periodicidad;
  DateTime fechaProximoCobro;

  Suscripcion({
    required this.nombre,
    required this.precio,
    required this.periodicidad,
    required this.fechaProximoCobro,
  });

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'precio': precio,
        'periodicidad': periodicidad,
        'fechaProximoCobro': fechaProximoCobro.toIso8601String(),
      };

  static Suscripcion fromMap(Map<String, dynamic> map) => Suscripcion(
        nombre: map['nombre'] ?? '',
        precio: (map['precio'] ?? 0.0).toDouble(),
        periodicidad: map['periodicidad'] ?? '',
        fechaProximoCobro: DateTime.parse(map['fechaProximoCobro']),
      );
}
