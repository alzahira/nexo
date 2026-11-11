class ItemCompra {
  String nombre;
  String cantidad;
  bool completado;

  ItemCompra({
    required this.nombre,
    required this.cantidad,
    this.completado = false,
  });
}