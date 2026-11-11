import 'package:flutter/material.dart';

class CasaScreen extends StatelessWidget {
  const CasaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vivienda'), backgroundColor: Colors.orange),
      body: const Center(child: Text('Gestión de casa y suministros')),
    );
  }
}