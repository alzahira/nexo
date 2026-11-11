import 'package:flutter/material.dart';
import '../../models/inmueble/propiedad.dart'; // Importamos tu modelo

class PropiedadesScreen extends StatelessWidget {
  // Datos de prueba (luego vendrán de Firebase)
  final List<Propiedad> misCasas = [
    Propiedad(alias: "Casa Torremolinos", direccion: "Calle Mayor 1", importeIBI: 450.0),
    Propiedad(alias: "Apartamento Playa", direccion: "Av. del Mar 12", importeIBI: 300.0),
  ];

  PropiedadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Propiedades'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: misCasas.length,
        itemBuilder: (context, index) {
          final casa = misCasas[index];
          return Card(
            margin: EdgeInsets.all(10),
            elevation: 5,
            child: ListTile(
              leading: Icon(Icons.home, color: Colors.blue, size: 40),
              title: Text(casa.alias, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(casa.direccion),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                debugPrint("Has pulsado en ${casa.alias}");
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => debugPrint("Añadir nueva propiedad"),
        child: Icon(Icons.add),
      ),
    );
  }
}