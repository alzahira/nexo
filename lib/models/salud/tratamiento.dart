class Tratamiento {
  String medicamento;
  String dosis;
  String frecuencia;
  DateTime fechaInicio;
  DateTime? fechaFin;
  String observaciones;

  Tratamiento({
    this.medicamento = 'Medicamento no indicado',
    this.dosis = 'Dosis no especificada',
    this.frecuencia = 'Frecuencia no indicada',
    required this.fechaInicio,
    this.fechaFin,
    this.observaciones = '',
  });

  Map<String, dynamic> toMap() => {
        'medicamento': medicamento,
        'dosis': dosis,
        'frecuencia': frecuencia,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin?.toIso8601String(),
        'observaciones': observaciones,
      };

  static Tratamiento fromMap(Map<String, dynamic> map) => Tratamiento(
        medicamento: map['medicamento'] ?? 'Medicamento no indicado',
        dosis: map['dosis'] ?? 'Dosis no especificada',
        frecuencia: map['frecuencia'] ?? 'Frecuencia no indicada',
        fechaInicio: DateTime.parse(map['fechaInicio']),
        fechaFin: map['fechaFin'] != null ? DateTime.parse(map['fechaFin']) : null,
        observaciones: map['observaciones'] ?? '',
      );
}
