import 'package:flutter/material.dart';
// 1. IMPORTA LA LIBRERÍA AQUÍ
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
import '../../models/vehiculos/vehiculo.dart';
import 'add_vehiculo_screen.dart';
import 'vehiculo_detail_screen.dart';
import '../theme/app_theme.dart';

class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({super.key});

  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  final List<Vehiculo> misCoches = [
    Vehiculo(
      matricula: '1234-ABC',
      marca: 'Peugeot',
      modelo: '508',
      combustible: 'Diesel',
      kilometrosActuales: 125000,
      numeroBastidor: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Vehículos')),
      body: ListView.builder(
        itemCount: misCoches.length,
        itemBuilder: (context, index) {
          final coche = misCoches[index];
          
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue.shade100,
                // 2. CAMBIAMOS EL ICONO POR FaIcon
                child: const FaIcon(
                  FontAwesomeIcons.carSide, 
                  color: Colors.blue, 
                  size: 24
                ),
              ),
              title: Text(
                '${coche.marca} ${coche.modelo}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Matrícula: ${coche.matricula}\n${coche.kilometrosActuales} km • ${coche.combustible}',
                  style: TextStyle(height: 1.4, color: Colors.grey.shade700),
                ),
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VehiculoDetailScreen(vehiculo: coche),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVehiculoScreen()),
          );

          if (result != null && result is Vehiculo) {
            setState(() {
              misCoches.add(result);
            });
          }
        },
        // 3. OPCIONAL: Icono de añadir más estilizado
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
    );
  }
}