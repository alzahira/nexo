import 'package:flutter/material.dart';

enum TipoEvento { salud, educacion, hogar, gestion, vehiculo, calendario }

class AppEvent {
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final TipoEvento tipo;
  final IconData icono;
  final Color color;

  /// Identificador del evento en Google Calendar (solo eventos importados).
  final String? googleId;

  /// `true` si el evento viene de Google Calendar y no de los datos locales.
  final bool desdeGoogle;

  AppEvent({
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.tipo,
    required this.icono,
    required this.color,
    this.googleId,
    this.desdeGoogle = false,
  });
}
