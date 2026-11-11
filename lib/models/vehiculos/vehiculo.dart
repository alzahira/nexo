import 'mantenimiento.dart';
import 'multa.dart';
import 'registro_itv.dart';
import 'parte_accidente.dart';
import 'impuesto_circulacion.dart';
import 'poliza_seguro.dart';

class Vehiculo {
  String matricula;
  String marca;
  String modelo;
  String numeroBastidor;
  String combustible;
  int kilometrosActuales;

  List<Mantenimiento> historialTaller;
  List<Multa> multas;
  List<RegistroITV> inspeccionesITV;
  List<ParteAccidente> partesAccidentes;
  List<ImpuestoCirculacion> historialImpuestos;
  SeguroVehiculo?
  seguroActual; // Usamos '?' porque puede que aún no hayamos metido el seguro

  Vehiculo({
    required this.matricula,
    required this.marca,
    required this.modelo,
    required this.numeroBastidor,
    required this.combustible,
    required this.kilometrosActuales,
    this.historialTaller = const [],
    this.multas = const [],
    this.inspeccionesITV = const [],
    this.partesAccidentes = const [],
    this.historialImpuestos = const [],
    this.seguroActual,
  });

  // Método para calcular el gasto total en el taller
  double gastoTotalTaller() {
    double total = 0;
    for (var registro in historialTaller) {
      total += registro.importe;
    }
    return total;
  }
}
