class DocumentoIdentidad {
  final String tipoDocumento; // DNI, Pasaporte, Carnet Conducir...
  final String numero;
  final DateTime fechaExpedicion;
  final DateTime fechaCaducidad;
  final String? archivoURL;

  DocumentoIdentidad({
    required this.tipoDocumento,
    required this.numero,
    required this.fechaExpedicion,
    required this.fechaCaducidad,
    this.archivoURL,
  });

  Map<String, dynamic> toMap() => {
        'tipoDocumento': tipoDocumento,
        'numero': numero,
        'fechaExpedicion': fechaExpedicion.toIso8601String(),
        'fechaCaducidad': fechaCaducidad.toIso8601String(),
        'archivoURL': archivoURL,
      };

  static DocumentoIdentidad fromMap(Map<String, dynamic> map) =>
      DocumentoIdentidad(
        tipoDocumento: map['tipoDocumento'] ?? '',
        numero: map['numero'] ?? '',
        fechaExpedicion: DateTime.parse(map['fechaExpedicion']),
        fechaCaducidad: DateTime.parse(map['fechaCaducidad']),
        archivoURL: map['archivoURL'],
      );
}