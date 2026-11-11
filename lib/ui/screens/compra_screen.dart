import 'package:flutter/material.dart';

class CompraScreen extends StatelessWidget {
  const CompraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de la Compra'), backgroundColor: Colors.purple),
      body: const Center(child: Text('No olvides el pan')),
    );
  }
}