class Examen {
  String materia;
  DateTime fechaHora;
  String temario;
  double? nota;
  String? idGoogleCalendar;

  Examen({
    required this.materia,
    required this.fechaHora,
    this.temario = '',
    this.nota,
    this.idGoogleCalendar,
  });

  Map<String, dynamic> toMap() => {
        'materia': materia,
        'fechaHora': fechaHora.toIso8601String(),
        'temario': temario,
        'nota': nota,
        'idGoogleCalendar': idGoogleCalendar,
      };

  static Examen fromMap(Map<String, dynamic> map) => Examen(
        materia: map['materia'] ?? '',
        fechaHora: DateTime.parse(map['fechaHora']),
        temario: map['temario'] ?? '',
        nota: map['nota'] != null ? (map['nota'] as num).toDouble() : null,
        idGoogleCalendar: map['idGoogleCalendar'],
      );
}
