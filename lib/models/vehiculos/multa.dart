class Multa {
  DateTime fechaInfraccion;
  String motivo;
  double importe;
  int puntosDetraidos;
  bool pagada;

  Multa({
    required this.fechaInfraccion,
    required this.motivo,
    required this.importe,
    this.puntosDetraidos = 0,
    this.pagada = false,
  });
}
