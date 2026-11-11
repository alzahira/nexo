class CalificacionMateria {
  String asignatura;
  double notaFinal;

  CalificacionMateria({
    required this.asignatura,
    required this.notaFinal,
  });

  Map<String, dynamic> toMap() => {
        'asignatura': asignatura,
        'notaFinal': notaFinal,
      };

  static CalificacionMateria fromMap(Map<String, dynamic> map) =>
      CalificacionMateria(
        asignatura: map['asignatura'] ?? '',
        notaFinal: (map['notaFinal'] ?? 0.0).toDouble(),
      );
}
