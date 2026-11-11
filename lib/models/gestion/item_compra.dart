class ItemCompra {
  String nombre;
  double cantidad;
  String unidad;
  bool estaComprado;

  /// Identificador de la tarea de Google Tasks que representa este producto.
  /// Se guarda para poder actualizarla o borrarla sin duplicarla.
  String? googleTaskId;

  ItemCompra({
    required this.nombre,
    required this.cantidad,
    this.unidad = 'unidades',
    this.estaComprado = false,
    this.googleTaskId,
  });

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'cantidad': cantidad,
        'unidad': unidad,
        'estaComprado': estaComprado,
        if (googleTaskId != null) 'googleTaskId': googleTaskId,
      };

  static ItemCompra fromMap(Map<String, dynamic> map) => ItemCompra(
        nombre: map['nombre'] ?? '',
        cantidad: (map['cantidad'] ?? 1.0).toDouble(),
        unidad: map['unidad'] ?? 'unidades',
        estaComprado: map['estaComprado'] ?? false,
        googleTaskId: map['googleTaskId'],
      );

  /// Texto de la cantidad tal y como se manda a Google Tasks: "2 kg", "1.5 l".
  String get cantidadTexto {
    final numero = cantidad == cantidad.roundToDouble()
        ? cantidad.toStringAsFixed(0)
        : cantidad.toStringAsFixed(1);
    return '$numero $unidad';
  }
}
