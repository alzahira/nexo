import '../usuarios/persona.dart';

class Paciente extends Persona {
  String idPaciente;

  Paciente({
    required super.nombre,
    required super.apellidos,
    required super.dni,
    required super.direccion,
    required super.telefono,
    required super.grupoSanguineo,
    required super.fechaNacimiento,
    required super.numSeguridadSocial,
    required super.medicoCabecera,
    required super.centroMedico,
    required super.alergiasConocidas,
    required this.idPaciente,
  });
}
