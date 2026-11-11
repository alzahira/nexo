import 'evento_escolar.dart';
import 'pago_educacion.dart';
import 'titulo.dart';
import 'curso_academico.dart';

class Alumno {
  String centroEducativo;
  String curso;
  String identificadorEscolar;
  String tutor;

  // Credenciales
  String usuarioIpasen;
  String passIpasen;
  String usuarioLibros;
  String passLibros;
  String conectarConClassroom;

  List<EventoEscolar> eventos = [];
  List<PagoEducacion> pagos = [];
  List<Titulo> titulos = [];
  List<CursoAcademico> historialAcademico = [];

  Alumno({
    this.centroEducativo = '',
    this.curso = '',
    this.identificadorEscolar = '',
    this.tutor = '',
    this.usuarioIpasen = '',
    this.passIpasen = '',
    this.usuarioLibros = '',
    this.passLibros = '',
    this.conectarConClassroom = '',
  });

  Map<String, dynamic> toMap() => {
        'centroEducativo': centroEducativo,
        'curso': curso,
        'identificadorEscolar': identificadorEscolar,
        'tutor': tutor,
        'usuarioIpasen': usuarioIpasen,
        'passIpasen': passIpasen,
        'usuarioLibros': usuarioLibros,
        'passLibros': passLibros,
        'conectarConClassroom': conectarConClassroom,
        'eventos': eventos.map((e) => e.toMap()).toList(),
        'pagos': pagos.map((p) => p.toMap()).toList(),
        'titulos': titulos.map((t) => t.toMap()).toList(),
        'historialAcademico': historialAcademico.map((c) => c.toMap()).toList(),
      };

  static Alumno fromMap(Map<String, dynamic> map) {
    final a = Alumno(
      centroEducativo: map['centroEducativo'] ?? '',
      curso: map['curso'] ?? '',
      identificadorEscolar: map['identificadorEscolar'] ?? '',
      tutor: map['tutor'] ?? '',
      usuarioIpasen: map['usuarioIpasen'] ?? '',
      passIpasen: map['passIpasen'] ?? '',
      usuarioLibros: map['usuarioLibros'] ?? '',
      passLibros: map['passLibros'] ?? '',
      conectarConClassroom: map['conectarConClassroom'] ?? '',
    );
    a.eventos = (map['eventos'] as List<dynamic>? ?? [])
        .map((e) => EventoEscolar.fromMap(e as Map<String, dynamic>))
        .toList();
    a.pagos = (map['pagos'] as List<dynamic>? ?? [])
        .map((e) => PagoEducacion.fromMap(e as Map<String, dynamic>))
        .toList();
    a.titulos = (map['titulos'] as List<dynamic>? ?? [])
        .map((e) => Titulo.fromMap(e as Map<String, dynamic>))
        .toList();
    a.historialAcademico = (map['historialAcademico'] as List<dynamic>? ?? [])
        .map((e) => CursoAcademico.fromMap(e as Map<String, dynamic>))
        .toList();
    return a;
  }
}
