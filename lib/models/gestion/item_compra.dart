class ItemCompra {
  String nombre;
  double cantidad;
  String unidad;
  bool estaComprado;

  ItemCompra({
    required this.nombre,
    required this.cantidad,
    this.unidad = 'unidades',
    this.estaComprado = false,
  });

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'cantidad': cantidad,
        'unidad': unidad,
        'estaComprado': estaComprado,
      };

  static ItemCompra fromMap(Map<String, dynamic> map) => ItemCompra(
        nombre: map['nombre'] ?? '',
        cantidad: (map['cantidad'] ?? 1.0).toDouble(),
        unidad: map['unidad'] ?? 'unidades',
        estaComprado: map['estaComprado'] ?? false,
      );
}
