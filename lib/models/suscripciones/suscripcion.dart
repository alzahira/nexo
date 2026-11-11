class Suscripcion {
  String nombre;
  double precio;
  bool activa;
  String periodicidad;

  Suscripcion({
    required this.nombre,
    required this.precio,
    this.activa = true,
    this.periodicidad = 'Mensual',
  });

  void desactivar() {
    activa = false;
  }
}
