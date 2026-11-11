class RegistroITV {
  DateTime fechaInspeccion;
  bool esFavorable;
  String observaciones;
  DateTime fechaVencimiento;

  RegistroITV({
    required this.fechaInspeccion,
    required this.esFavorable,
    required this.observaciones,
    required this.fechaVencimiento,
  });

  // Método para verificar si la ITV está caducada
  bool estaCaducada() {
    return DateTime.now().isAfter(fechaVencimiento);
  }
}
