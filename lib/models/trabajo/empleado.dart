import 'nomina.dart';
import 'contrato.dart';

class Empleado {
  String empresaActual;
  String puesto;
  DateTime fechaIngreso;
  String numSeguridadSocial;

  List<Nomina> nominas;
  List<Contrato> contratos;

  Empleado({
    required this.empresaActual,
    required this.puesto,
    required this.fechaIngreso,
    required this.numSeguridadSocial,
    List<Nomina>? nominas,
    List<Contrato>? contratos,
  })  : nominas = nominas ?? [],
        contratos = contratos ?? [];

  Map<String, dynamic> toMap() => {
        'empresaActual': empresaActual,
        'puesto': puesto,
        'fechaIngreso': fechaIngreso.toIso8601String(),
        'numSeguridadSocial': numSeguridadSocial,
        'nominas': nominas.map((n) => n.toMap()).toList(),
        'contratos': contratos.map((c) => c.toMap()).toList(),
      };

  static Empleado fromMap(Map<String, dynamic> map) {
    final e = Empleado(
      empresaActual: map['empresaActual'] ?? '',
      puesto: map['puesto'] ?? '',
      fechaIngreso: DateTime.parse(map['fechaIngreso']),
      numSeguridadSocial: map['numSeguridadSocial'] ?? '',
    );
    e.nominas = (map['nominas'] as List<dynamic>? ?? [])
        .map((n) => Nomina.fromMap(n as Map<String, dynamic>))
        .toList();
    e.contratos = (map['contratos'] as List<dynamic>? ?? [])
        .map((c) => Contrato.fromMap(c as Map<String, dynamic>))
        .toList();
    return e;
  }
}
