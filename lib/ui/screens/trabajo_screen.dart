import 'package:flutter/material.dart';

class TrabajoScreen extends StatelessWidget {
  const TrabajoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Trabajo'), backgroundColor: Colors.brown),
      body: const Center(child: Text('Nóminas y contratos')),
    );
  }
}