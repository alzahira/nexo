class Electrodomestico {
  String nombre; // Ej: "Lavadora", "Lavavajillas"
  String marca;
  String modelo;
  DateTime fechaCompra;
  int mesesGarantia;

  Electrodomestico({
    required this.nombre,
    required this.marca,
    required this.modelo,
    required this.fechaCompra,
    required this.mesesGarantia,
  });

  bool estaEnGarantia() {
    final fechaFinGarantia = fechaCompra.add(
      Duration(days: mesesGarantia * 30),
    );
    return DateTime.now().isBefore(fechaFinGarantia);
  }
}
