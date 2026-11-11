import 'package:flutter/material.dart';

class MenusScreen extends StatelessWidget {
  const MenusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menús Semanales'), backgroundColor: Colors.pink),
      body: const Center(child: Text('¿Qué comemos hoy?')),
    );
  }
}