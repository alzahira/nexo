class ImpuestoCirculacion {
  int anio;
  double importe;
  bool pagado;
  DateTime fechaLimitePago;

  ImpuestoCirculacion({
    required this.anio,
    required this.importe,
    required this.pagado,
    required this.fechaLimitePago,
  });
}
