class PruebaMedica {
  DateTime fecha;
  String tipoPrueba;
  String centro;
  String resultado;
  String? archivoURL;

  PruebaMedica({
    required this.fecha,
    required this.tipoPrueba,
    this.centro = '',
    this.resultado = '',
    this.archivoURL,
  });

  Map<String, dynamic> toMap() => {
        'fecha': fecha.toIso8601String(),
        'tipoPrueba': tipoPrueba,
        'centro': centro,
        'resultado': resultado,
        'archivoURL': archivoURL,
      };

  static PruebaMedica fromMap(Map<String, dynamic> map) => PruebaMedica(
        fecha: DateTime.parse(map['fecha']),
        tipoPrueba: map['tipoPrueba'] ?? '',
        centro: map['centro'] ?? '',
        resultado: map['resultado'] ?? '',
        archivoURL: map['archivoURL'],
      );
}
