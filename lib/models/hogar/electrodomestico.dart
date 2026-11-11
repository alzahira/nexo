class Electrodomestico {
  String nombre;
  String marca;
  DateTime fechaCompra;
  int mesesGarantia;
  double precio;
  String? ubicacion;
  String? facturaURL;

  Electrodomestico({
    required this.nombre,
    required this.marca,
    required this.fechaCompra,
    required this.mesesGarantia,
    required this.precio,
    this.ubicacion,
    this.facturaURL,
  });

  bool get estaEnGarantia {
    final expiracion = DateTime(
      fechaCompra.year,
      fechaCompra.month + mesesGarantia,
      fechaCompra.day,
    );
    return DateTime.now().isBefore(expiracion);
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'marca': marca,
        'fechaCompra': fechaCompra.toIso8601String(),
        'mesesGarantia': mesesGarantia,
        'precio': precio,
        'ubicacion': ubicacion,
        'facturaURL': facturaURL,
      };

  static Electrodomestico fromMap(Map<String, dynamic> map) => Electrodomestico(
        nombre: map['nombre'] ?? '',
        marca: map['marca'] ?? '',
        fechaCompra: DateTime.parse(map['fechaCompra']),
        mesesGarantia: map['mesesGarantia'] ?? 0,
        precio: (map['precio'] ?? 0.0).toDouble(),
        ubicacion: map['ubicacion'],
        facturaURL: map['facturaURL'],
      );
}
