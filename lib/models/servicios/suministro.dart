class Suministro {
  String tipo; // Electricidad, Agua, Gas, Fibra
  String compania;
  String identificadorContrato;
  String potenciaContratada;
  DateTime fechaVencimientoTarifa;
  double costeBase;
  String notas;

  Suministro({
    required this.tipo,
    required this.compania,
    required this.identificadorContrato,
    required this.potenciaContratada,
    required this.fechaVencimientoTarifa,
    required this.costeBase,
    this.notas = "",
  });
}