class VisitaHistorial {
  DateTime fecha;
  String incidencia;
  String centroSalud;
  String valoracion;
  String tratamientoRecomendado;
  String? fotoInforme;

  VisitaHistorial({
    required this.fecha,
    required this.incidencia,
    required this.centroSalud,
    this.valoracion = '',
    this.tratamientoRecomendado = '',
    this.fotoInforme,
  });

  Map<String, dynamic> toMap() => {
        'fecha': fecha.toIso8601String(),
        'incidencia': incidencia,
        'centroSalud': centroSalud,
        'valoracion': valoracion,
        'tratamientoRecomendado': tratamientoRecomendado,
        'fotoInforme': fotoInforme,
      };

  static VisitaHistorial fromMap(Map<String, dynamic> map) => VisitaHistorial(
        fecha: DateTime.parse(map['fecha']),
        incidencia: map['incidencia'] ?? '',
        centroSalud: map['centroSalud'] ?? '',
        valoracion: map['valoracion'] ?? '',
        tratamientoRecomendado: map['tratamientoRecomendado'] ?? '',
        fotoInforme: map['fotoInforme'],
      );
}
