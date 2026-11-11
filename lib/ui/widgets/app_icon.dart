import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Icono que acepta tanto un `IconData` de Material como un `FaIconData`
/// de Font Awesome.
///
/// En font_awesome_flutter 11 `FaIconData` dejó de ser un `IconData`, así que
/// los helpers que mezclan ambos necesitan este envoltorio.
class AppIcon extends StatelessWidget {
  final Object icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final data = icon;
    if (data is FaIconData) {
      return FaIcon(
        data,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      );
    }
    return Icon(
      data as IconData,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
    );
  }
}
