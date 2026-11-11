class SeguroVehiculo {
  String compania;
  String numeroPoliza;
  String tipoCobertura; // Ej: "Todo riesgo con franquicia"
  String telefonoAsistencia;
  DateTime fechaVencimiento;

  SeguroVehiculo({
    required this.compania,
    required this.numeroPoliza,
    required this.tipoCobertura,
    required this.telefonoAsistencia,
    required this.fechaVencimiento,
  });
}
