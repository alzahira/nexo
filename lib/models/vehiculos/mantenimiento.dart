class Mantenimiento {
  DateTime fecha;
  int kilometrajeEnEseMomento;
  String taller;
  String descripcion;
  double importe;

  Mantenimiento({
    required this.fecha,
    required this.kilometrajeEnEseMomento,
    required this.taller,
    required this.descripcion,
    required this.importe,
  });
}
