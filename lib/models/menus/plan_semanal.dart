import 'menu_diario.dart';

class PlanSemanal {
  DateTime fechaInicio;
  String estado; // Borrador, Confirmado, Terminado

  List<MenuDiario> menus;

  PlanSemanal({
    required this.fechaInicio,
    required this.estado,
    this.menus = const [],
  });
}