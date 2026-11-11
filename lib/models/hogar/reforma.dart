class Reforma {
  String descripcion;
  double coste;
  DateTime fechaFin;
  String contratista;
  String? facturaURL;

  Reforma({
    required this.descripcion,
    required this.coste,
    required this.fechaFin,
    required this.contratista,
    this.facturaURL,
  });

  Map<String, dynamic> toMap() => {
        'descripcion': descripcion,
        'coste': coste,
        'fechaFin': fechaFin.toIso8601String(),
        'contratista': contratista,
        'facturaURL': facturaURL,
      };

  static Reforma fromMap(Map<String, dynamic> map) => Reforma(
        descripcion: map['descripcion'] ?? '',
        coste: (map['coste'] ?? 0.0).toDouble(),
        fechaFin: DateTime.parse(map['fechaFin']),
        contratista: map['contratista'] ?? '',
        facturaURL: map['facturaURL'],
      );
}
