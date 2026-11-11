import 'package:flutter/material.dart';

enum TipoEvento { salud, educacion, hogar, gestion, vehiculo }

class AppEvent {
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final TipoEvento tipo;
  final IconData icono;
  final Color color;

  AppEvent({
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.tipo,
    required this.icono,
    required this.color,
  });
}
