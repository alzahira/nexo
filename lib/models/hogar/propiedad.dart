import 'seguro_hogar.dart';
import 'habitacion.dart';
import 'electrodomestico.dart';
import 'reforma.dart';

class Propiedad {
  String alias;
  String direccion;
  String referenciaCatastral;
  double ibi;
  DateTime? fechaCompra;
  double? valorCompra;

  SeguroHogar? seguro;
  List<Habitacion> habitaciones;
  List<Electrodomestico> electrodomesticos;
  List<Reforma> reformas;

  Propiedad({
    required this.alias,
    required this.direccion,
    required this.referenciaCatastral,
    required this.ibi,
    this.fechaCompra,
    this.valorCompra,
    this.seguro,
    List<Habitacion>? habitaciones,
    List<Electrodomestico>? electrodomesticos,
    List<Reforma>? reformas,
  })  : habitaciones = habitaciones ?? [],
        electrodomesticos = electrodomesticos ?? [],
        reformas = reformas ?? [];

  Map<String, dynamic> toMap() => {
        'alias': alias,
        'direccion': direccion,
        'referenciaCatastral': referenciaCatastral,
        'IBI': ibi,
        'fechaCompra': fechaCompra?.toIso8601String(),
        'valorCompra': valorCompra,
        'seguro': seguro?.toMap(),
        'habitaciones': habitaciones.map((h) => h.toMap()).toList(),
        'electrodomesticos': electrodomesticos.map((e) => e.toMap()).toList(),
        'reformas': reformas.map((r) => r.toMap()).toList(),
      };

  static Propiedad fromMap(Map<String, dynamic> map) {
    final p = Propiedad(
      alias: map['alias'] ?? '',
      direccion: map['direccion'] ?? '',
      referenciaCatastral: map['referenciaCatastral'] ?? '',
      ibi: (map['IBI'] ?? 0.0).toDouble(),
      fechaCompra: map['fechaCompra'] != null ? DateTime.parse(map['fechaCompra']) : null,
      valorCompra: map['valorCompra'] != null ? (map['valorCompra'] as num).toDouble() : null,
      seguro: map['seguro'] != null ? SeguroHogar.fromMap(map['seguro'] as Map<String, dynamic>) : null,
    );
    p.habitaciones = (map['habitaciones'] as List<dynamic>? ?? [])
        .map((e) => Habitacion.fromMap(e as Map<String, dynamic>))
        .toList();
    p.electrodomesticos = (map['electrodomesticos'] as List<dynamic>? ?? [])
        .map((e) => Electrodomestico.fromMap(e as Map<String, dynamic>))
        .toList();
    p.reformas = (map['reformas'] as List<dynamic>? ?? [])
        .map((e) => Reforma.fromMap(e as Map<String, dynamic>))
        .toList();
    return p;
  }
}
