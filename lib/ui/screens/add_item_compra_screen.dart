import 'package:flutter/material.dart';
import '../../models/gestion/item_compra.dart';

class AddItemCompraScreen extends StatefulWidget {
  const AddItemCompraScreen({super.key});

  @override
  State<AddItemCompraScreen> createState() => _AddItemCompraScreenState();
}

class _AddItemCompraScreenState extends State<AddItemCompraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _cantCtrl = TextEditingController(text: '1');
  String _unidad = 'unidades';

  @override
  void dispose() {
    _nombreCtrl.dispose(); _cantCtrl.dispose(); super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, ItemCompra(
        nombre: _nombreCtrl.text,
        cantidad: double.tryParse(_cantCtrl.text) ?? 1.0,
        unidad: _unidad,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Producto'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: '¿Qué falta?', prefixIcon: Icon(Icons.shopping_bag, color: Colors.green)),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cantCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Cantidad'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _unidad,
                      decoration: const InputDecoration(labelText: 'Unidad'),
                      items: ['unidades', 'kg', 'g', 'l', 'pack', 'bote'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (v) => setState(() => _unidad = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardar,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: const Text('Añadir a la lista'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
