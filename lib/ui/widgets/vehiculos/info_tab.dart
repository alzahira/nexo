import 'package:flutter/material.dart';
import '../../../models/vehiculos/vehiculo.dart';

class InfoTab extends StatelessWidget {
  final Vehiculo vehiculo;

  const InfoTab({super.key, required this.vehiculo});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          title: const Text('Matrícula'),
          subtitle: Text(vehiculo.matricula),
        ),
        ListTile(
          title: const Text('Marca'),
          subtitle: Text(vehiculo.marca),
        ),
        ListTile(
          title: const Text('Modelo'),
          subtitle: Text(vehiculo.modelo),
        ),
        ListTile(
          title: const Text('Combustible'),
          subtitle: Text(vehiculo.combustible),
        ),
        ListTile(
          title: const Text('Kilómetros'),
          subtitle: Text('${vehiculo.kilometrosActuales} km'),
        ),
      ],
    );
  }
}
