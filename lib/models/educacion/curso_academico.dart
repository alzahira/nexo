import 'calificacion_materia.dart';
import 'examen.dart';
import 'tarea.dart';

class CursoAcademico {
  String nombreCurso;
  String nivel;
  String centro;
  double mediaGlobal;
  String? boletinFinalURL;
  List<CalificacionMateria> calificaciones;
  List<Examen> examenes;
  List<Tarea> tareas;

  CursoAcademico({
    required this.nombreCurso,
    required this.nivel,
    required this.centro,
    this.mediaGlobal = 0.0,
    this.boletinFinalURL,
    List<CalificacionMateria>? calificaciones,
    List<Examen>? examenes,
    List<Tarea>? tareas,
  }) : calificaciones = calificaciones ?? [],
       examenes = examenes ?? [],
       tareas = tareas ?? [];

  Map<String, dynamic> toMap() => {
        'nombreCurso': nombreCurso,
        'nivel': nivel,
        'centro': centro,
        'mediaGlobal': mediaGlobal,
        'boletinFinalURL': boletinFinalURL,
        'calificaciones': calificaciones.map((c) => c.toMap()).toList(),
        'examenes': examenes.map((e) => e.toMap()).toList(),
        'tareas': tareas.map((t) => t.toMap()).toList(),
      };

  static CursoAcademico fromMap(Map<String, dynamic> map) => CursoAcademico(
        nombreCurso: map['nombreCurso'] ?? '',
        nivel: map['nivel'] ?? '',
        centro: map['centro'] ?? '',
        mediaGlobal: (map['mediaGlobal'] ?? 0.0).toDouble(),
        boletinFinalURL: map['boletinFinalURL'],
        calificaciones: (map['calificaciones'] as List<dynamic>? ?? [])
            .map((e) => CalificacionMateria.fromMap(e as Map<String, dynamic>))
            .toList(),
        examenes: (map['examenes'] as List<dynamic>? ?? [])
            .map((e) => Examen.fromMap(e as Map<String, dynamic>))
            .toList(),
        tareas: (map['tareas'] as List<dynamic>? ?? [])
            .map((e) => Tarea.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
}
