class EventoEscolar {
  String tipo;
  DateTime fecha;
  bool necesitaAutorizacion;
  String? documentoURL;

  EventoEscolar({
    required this.tipo,
    required this.fecha,
    this.necesitaAutorizacion = false,
    this.documentoURL,
  });

  Map<String, dynamic> toMap() => {
        'tipo': tipo,
        'fecha': fecha.toIso8601String(),
        'necesitaAutorizacion': necesitaAutorizacion,
        'documentoURL': documentoURL,
      };

  static EventoEscolar fromMap(Map<String, dynamic> map) => EventoEscolar(
        tipo: map['tipo'] ?? '',
        fecha: DateTime.parse(map['fecha']),
        necesitaAutorizacion: map['necesitaAutorizacion'] ?? false,
        documentoURL: map['documentoURL'],
      );
}
