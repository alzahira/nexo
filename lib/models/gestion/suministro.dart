class Suministro {
  String tipo;
  String compania;
  String? nContrato;
  double costeMesAnterior;

  Suministro({
    required this.tipo,
    required this.compania,
    this.nContrato,
    this.costeMesAnterior = 0.0,
  });

  Map<String, dynamic> toMap() => {
        'tipo': tipo,
        'compania': compania,
        'nContrato': nContrato,
        'costeMesAnterior': costeMesAnterior,
      };

  static Suministro fromMap(Map<String, dynamic> map) => Suministro(
        tipo: map['tipo'] ?? '',
        compania: map['compania'] ?? '',
        nContrato: map['nContrato'],
        costeMesAnterior: (map['costeMesAnterior'] ?? 0.0).toDouble(),
      );
}
