class SeguroHogar {
  String compania;
  String nPoliza;
  String telefonoAsistencia;
  double primaAnual;
  DateTime fechaVencimiento;
  String? archivoURL;

  SeguroHogar({
    required this.compania,
    required this.nPoliza,
    required this.telefonoAsistencia,
    required this.primaAnual,
    required this.fechaVencimiento,
    this.archivoURL,
  });

  Map<String, dynamic> toMap() => {
        'compania': compania,
        'nPoliza': nPoliza,
        'telefonoAsistencia': telefonoAsistencia,
        'primaAnual': primaAnual,
        'fechaVencimiento': fechaVencimiento.toIso8601String(),
        'archivoURL': archivoURL,
      };

  static SeguroHogar fromMap(Map<String, dynamic> map) => SeguroHogar(
        compania: map['compania'] ?? '',
        nPoliza: map['nPoliza'] ?? '',
        telefonoAsistencia: map['telefonoAsistencia'] ?? '',
        primaAnual: (map['primaAnual'] ?? 0.0).toDouble(),
        fechaVencimiento: DateTime.parse(map['fechaVencimiento']),
        archivoURL: map['archivoURL'],
      );
}
