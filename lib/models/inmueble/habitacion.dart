class Habitacion {
  String nombre; // Ej: "Salón", "Dormitorio Principal"
  String marcaPintura;
  String codigoColorPintura;
  DateTime?
  fechaUltimaPintura; // El '?' significa que puede ser un dato vacío (nulo)

  Habitacion({
    required this.nombre,
    required this.marcaPintura,
    required this.codigoColorPintura,
    this.fechaUltimaPintura, // No es obligatorio (required) porque quizás no lo sabes
  });
}
