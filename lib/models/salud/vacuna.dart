class Vacuna {
  String nombre;
  String dosis;
  String laboratorio;
  DateTime fechaPuesta;
  DateTime? fechaProximaDosis;
  String? fotoPath;

  Vacuna({
    required this.nombre,
    this.dosis = '',
    this.laboratorio = '',
    required this.fechaPuesta,
    this.fechaProximaDosis,
    this.fotoPath,
  });

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'dosis': dosis,
        'laboratorio': laboratorio,
        'fechaPuesta': fechaPuesta.toIso8601String(),
        'fechaProximaDosis': fechaProximaDosis?.toIso8601String(),
        'fotoPath': fotoPath,
      };

  static Vacuna fromMap(Map<String, dynamic> map) => Vacuna(
        nombre: map['nombre'] ?? '',
        dosis: map['dosis'] ?? '',
        laboratorio: map['laboratorio'] ?? '',
        fechaPuesta: DateTime.parse(map['fechaPuesta']),
        fechaProximaDosis: map['fechaProximaDosis'] != null
            ? DateTime.parse(map['fechaProximaDosis'])
            : null,
        fotoPath: map['fotoPath'],
      );
}
