import 'habitacion.dart';
import 'electrodomestico.dart';
import 'seguro_hogar.dart';

class Propiedad {
  String alias;
  String direccion;
  double importeIBI;

  // Listas de todo lo que compone la vivienda
  List<Habitacion> habitaciones;
  List<Electrodomestico> electrodomesticos;
  List<SeguroHogar> seguros;

  Propiedad({
    required this.alias,
    required this.direccion,
    required this.importeIBI,
    this.habitaciones = const [],
    this.electrodomesticos = const [],
    this.seguros = const [],
  });
}
