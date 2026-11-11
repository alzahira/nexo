import 'package:flutter/foundation.dart';

class CitaMedica {
  String especialidad;
  String doctor;
  String centro;
  DateTime fecha;
  String? notas;

  CitaMedica({
    this.especialidad = 'Sin nombre',
    this.doctor = 'No asignado',
    this.centro = 'Centro no especificado',
    required this.fecha,
    this.notas,
  });

  Map<String, dynamic> toMap() => {
        'especialidad': especialidad,
        'doctor': doctor,
        'centro': centro,
        'fecha': fecha.toIso8601String(),
        'notas': notas,
      };

  static CitaMedica fromMap(Map<String, dynamic> map) {
    try {
      return CitaMedica(
        especialidad: map['especialidad'] ?? 'Sin nombre',
        doctor: map['doctor'] ?? 'No asignado',
        centro: map['centro'] ?? 'Centro no especificado',
        fecha: map['fecha'] != null ? DateTime.parse(map['fecha']) : DateTime.now(),
        notas: map['notas'],
      );
    } catch (e) {
      debugPrint("Error al parsear CitaMedica: $e");
      return CitaMedica(fecha: DateTime.now(), especialidad: 'Error al cargar');
    }
  }
}
