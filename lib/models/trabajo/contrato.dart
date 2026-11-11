class Contrato {
  String tipoContrato;
  String identificadorContrato;
  DateTime fechaInicio;
  DateTime? fechaFin;
  String? archivoURL;

  Contrato({
    required this.tipoContrato,
    required this.identificadorContrato,
    required this.fechaInicio,
    this.fechaFin,
    this.archivoURL,
  });

  Map<String, dynamic> toMap() => {
        'tipoContrato': tipoContrato,
        'identificadorContrato': identificadorContrato,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin?.toIso8601String(),
        'archivoURL': archivoURL,
      };

  static Contrato fromMap(Map<String, dynamic> map) => Contrato(
        tipoContrato: map['tipoContrato'] ?? '',
        identificadorContrato: map['identificadorContrato'] ?? '',
        fechaInicio: DateTime.parse(map['fechaInicio']),
        fechaFin: map['fechaFin'] != null ? DateTime.parse(map['fechaFin']) : null,
        archivoURL: map['archivoURL'],
      );
}
