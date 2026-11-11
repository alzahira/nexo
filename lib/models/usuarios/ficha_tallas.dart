class FichaTallas {
  final String tallaCamisa;
  final String tallaPantalon;
  final double tallaCalzado;
  final double? tallaSujetador; // Opcional según la persona

  FichaTallas({
    required this.tallaCamisa,
    required this.tallaPantalon,
    required this.tallaCalzado,
    this.tallaSujetador,
  });

  Map<String, dynamic> toMap() => {
        'tallaCamisa': tallaCamisa,
        'tallaPantalon': tallaPantalon,
        'tallaCalzado': tallaCalzado,
        'tallaSujetador': tallaSujetador,
      };

  static FichaTallas fromMap(Map<String, dynamic> map) => FichaTallas(
        tallaCamisa: map['tallaCamisa'] ?? '',
        tallaPantalon: map['tallaPantalon'] ?? '',
        tallaCalzado: (map['tallaCalzado'] ?? 0.0).toDouble(),
        tallaSujetador: map['tallaSujetador'] != null
            ? (map['tallaSujetador'] as num).toDouble()
            : null,
      );
}