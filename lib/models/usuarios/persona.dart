import 'package:flutter/foundation.dart';
import '../salud/cita_medica.dart';
import '../salud/prueba_medica.dart';
import '../salud/visita_historial.dart';
import '../salud/tratamiento.dart';
import '../salud/vacuna.dart';
import '../salud/aviso_salud.dart';
import '../educacion/alumno.dart';
import '../trabajo/empleado.dart';
import 'documento_identidad.dart';
import 'ficha_tallas.dart';

class Persona {
  String nombre;
  String apellidos;
  String dni;
  String direccion;
  String telefono;
  String grupoSanguineo;
  DateTime fechaNacimiento;
  String? fotoUrl;

  // Datos Médicos Específicos
  String numSeguridadSocial;
  String medicoCabecera;
  String centroMedico;
  String alergiasConocidas;

  // Listas de salud e información
  List<DocumentoIdentidad> documentos = [];
  FichaTallas? tallas;
  List<CitaMedica> citas = [];
  List<Tratamiento> tratamientos = [];
  List<VisitaHistorial> historial = [];
  List<Vacuna> vacunas = [];
  List<PruebaMedica> pruebasMedicas = [];
  List<AvisoSalud> avisos = [];

  // Perfil Educativo (opcional)
  Alumno? rolEstudiante;

  // Perfil Laboral (opcional)
  Empleado? rolEmpleado;

  Persona({
    required this.nombre,
    required this.apellidos,
    required this.dni,
    required this.direccion,
    required this.telefono,
    required this.grupoSanguineo,
    required this.fechaNacimiento,
    this.numSeguridadSocial = '',
    this.medicoCabecera = '',
    this.centroMedico = '',
    this.alergiasConocidas = 'Ninguna',
    this.fotoUrl,
  });

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'apellidos': apellidos,
        'dni': dni,
        'direccion': direccion,
        'telefono': telefono,
        'grupoSanguineo': grupoSanguineo,
        'fechaNacimiento': fechaNacimiento.toIso8601String(),
        'fotoUrl': fotoUrl,
        'numSeguridadSocial': numSeguridadSocial,
        'medicoCabecera': medicoCabecera,
        'centroMedico': centroMedico,
        'alergiasConocidas': alergiasConocidas,
        'documentos': documentos.map((d) => d.toMap()).toList(),
        'tallas': tallas?.toMap(),
        'citas': citas.map((c) => c.toMap()).toList(),
        'tratamientos': tratamientos.map((t) => t.toMap()).toList(),
        'historial': historial.map((h) => h.toMap()).toList(),
        'vacunas': vacunas.map((v) => v.toMap()).toList(),
        'pruebasMedicas': pruebasMedicas.map((p) => p.toMap()).toList(),
        'avisos': avisos.map((a) => a.toMap()).toList(),
        'rolEstudiante': rolEstudiante?.toMap(),
        'rolEmpleado': rolEmpleado?.toMap(),
      };

  static Persona fromMap(Map<String, dynamic> map) {
    try {
      final p = Persona(
        nombre: map['nombre'] ?? '',
        apellidos: map['apellidos'] ?? '',
        dni: map['dni'] ?? '',
        direccion: map['direccion'] ?? '',
        telefono: map['telefono'] ?? '',
        grupoSanguineo: map['grupoSanguineo'] ?? '',
        fechaNacimiento: map['fechaNacimiento'] != null ? DateTime.parse(map['fechaNacimiento']) : DateTime.now(),
        numSeguridadSocial: map['numSeguridadSocial'] ?? '',
        medicoCabecera: map['medicoCabecera'] ?? '',
        centroMedico: map['centroMedico'] ?? '',
        alergiasConocidas: map['alergiasConocidas'] ?? 'Ninguna',
        fotoUrl: map['fotoUrl'],
      );
      p.documentos = (map['documentos'] as List<dynamic>? ?? [])
          .map((e) => DocumentoIdentidad.fromMap(e as Map<String, dynamic>))
          .toList();
      p.tallas = map['tallas'] != null
          ? FichaTallas.fromMap(map['tallas'] as Map<String, dynamic>)
          : null;
      p.citas = (map['citas'] as List<dynamic>? ?? [])
          .map((e) => CitaMedica.fromMap(e as Map<String, dynamic>))
          .toList();
      p.tratamientos = (map['tratamientos'] as List<dynamic>? ?? [])
          .map((e) => Tratamiento.fromMap(e as Map<String, dynamic>))
          .toList();
      p.historial = (map['historial'] as List<dynamic>? ?? [])
          .map((e) => VisitaHistorial.fromMap(e as Map<String, dynamic>))
          .toList();
      p.vacunas = (map['vacunas'] as List<dynamic>? ?? [])
          .map((e) => Vacuna.fromMap(e as Map<String, dynamic>))
          .toList();
      p.pruebasMedicas = (map['pruebasMedicas'] as List<dynamic>? ?? [])
          .map((e) => PruebaMedica.fromMap(e as Map<String, dynamic>))
          .toList();
      p.avisos = (map['avisos'] as List<dynamic>? ?? [])
          .map((e) => AvisoSalud.fromMap(e as Map<String, dynamic>))
          .toList();
      p.rolEstudiante = map['rolEstudiante'] != null
          ? Alumno.fromMap(map['rolEstudiante'] as Map<String, dynamic>)
          : null;
      p.rolEmpleado = map['rolEmpleado'] != null
          ? Empleado.fromMap(map['rolEmpleado'] as Map<String, dynamic>)
          : null;
      return p;
    } catch (e) {
      debugPrint("Error crítico al mapear Persona: $e");
      return Persona(
        nombre: "Error al cargar",
        apellidos: "",
        dni: map['dni'] ?? "0",
        direccion: "",
        telefono: "",
        grupoSanguineo: "",
        fechaNacimiento: DateTime.now(),
      );
    }
  }
}