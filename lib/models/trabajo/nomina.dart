class Nomina {
  int mes;
  int ano;
  double importeLiquido;
  String? archivoURL;

  Nomina({
    required this.mes,
    required this.ano,
    required this.importeLiquido,
    this.archivoURL,
  });

  Map<String, dynamic> toMap() => {
        'mes': mes,
        'ano': ano,
        'importeLiquido': importeLiquido,
        'archivoURL': archivoURL,
      };

  static Nomina fromMap(Map<String, dynamic> map) => Nomina(
        mes: map['mes'] ?? 1,
        ano: map['ano'] ?? DateTime.now().year,
        importeLiquido: (map['importeLiquido'] ?? 0.0).toDouble(),
        archivoURL: map['archivoURL'],
      );
}
