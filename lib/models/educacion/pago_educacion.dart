class PagoEducacion {
  String concepto;
  String periodicidad;

  PagoEducacion({
    required this.concepto,
    required this.periodicidad,
  });

  Map<String, dynamic> toMap() => {
        'concepto': concepto,
        'periodicidad': periodicidad,
      };

  static PagoEducacion fromMap(Map<String, dynamic> map) => PagoEducacion(
        concepto: map['concepto'] ?? '',
        periodicidad: map['periodicidad'] ?? '',
      );
}
