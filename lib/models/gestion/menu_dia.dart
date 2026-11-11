class MenuDia {
  String diaSemana;
  String? desayuno;
  String? almuerzo;
  String? cena;

  MenuDia({
    required this.diaSemana,
    this.desayuno,
    this.almuerzo,
    this.cena,
  });

  Map<String, dynamic> toMap() => {
        'diaSemana': diaSemana,
        'desayuno': desayuno,
        'almuerzo': almuerzo,
        'cena': cena,
      };

  static MenuDia fromMap(Map<String, dynamic> map) => MenuDia(
        diaSemana: map['diaSemana'] ?? '',
        desayuno: map['desayuno'],
        almuerzo: map['almuerzo'],
        cena: map['cena'],
      );
}
