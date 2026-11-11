import 'package:flutter/material.dart';
import 'package:app_home/ui/screens/salud_screen.dart';
import '../../models/usuarios/persona.dart'; // Importante para recibir la persona
// Importa el resto de tus pantallas...
import 'vehiculos_screen.dart'; 
// import 'casa_screen.dart'; ...

class Dashboard extends StatelessWidget {
  // Añadimos la persona al constructor para que Salud y otros sepan de quién son los datos
  final Persona persona;

  const Dashboard({super.key, required this.persona});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categorias = [
      {'nombre': 'Salud', 'icono': Icons.medical_services, 'color': Colors.red},
      {'nombre': 'Vehículos', 'icono': Icons.directions_car, 'color': Colors.blue},
      {'nombre': 'Educación', 'icono': Icons.school, 'color': Colors.green},
      {'nombre': 'Trabajo', 'icono': Icons.work, 'color': Colors.brown},
      {'nombre': 'Casa', 'icono': Icons.home, 'color': Colors.orange},
      {'nombre': 'Menús', 'icono': Icons.restaurant, 'color': Colors.pink},
      {'nombre': 'Compra', 'icono': Icons.shopping_cart, 'color': Colors.purple},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('AppHome - ${persona.nombre}'), // Personalizamos el título
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final item = categorias[index];
          final String nombre = item['nombre'] as String;
          final IconData icono = item['icono'] as IconData;
          final Color color = item['color'] as Color;

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                // Definimos la lógica de navegación AQUÍ de forma limpia
                Widget nextScreen;

                switch (nombre) {
                  case 'Salud':
                    // PASAMOS LA PERSONA a SaludScreen
                    nextScreen = SaludScreen(persona: persona);
                    break;
                  case 'Vehículos':
                    nextScreen = const VehiculosScreen();
                    break;
                  // Añade los casos para las demás pantallas cuando las tengas listas:
                  // case 'Educación': nextScreen = const EducacionScreen(); break;
                  default:
                    return; // Si no hay pantalla, no hace nada
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => nextScreen),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icono, size: 45, color: color),
                  const SizedBox(height: 12),
                  Text(
                    nombre,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}