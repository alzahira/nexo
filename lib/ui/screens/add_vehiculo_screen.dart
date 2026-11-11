import 'package:flutter/material.dart';
import '../../models/vehiculos/vehiculo.dart';
import 'package:flutter/services.dart';

class AddVehiculoScreen extends StatefulWidget {
  const AddVehiculoScreen({super.key});

  @override
  State<AddVehiculoScreen> createState() => _AddVehiculoScreenState();
}

class _AddVehiculoScreenState extends State<AddVehiculoScreen> {
  // 1. La "llave" para controlar el formulario
  final _formKey = GlobalKey<FormState>();

  // 2. Controladores para capturar el texto
  final _matriculaCtrl = TextEditingController();
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  final _kmCtrl = TextEditingController();
  String _combustible = 'Gasolina'; // Valor por defecto

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Vehículo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _matriculaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Matrícula',
                  icon: Icon(Icons.pin),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Introduce la matrícula' : null,
              ),
              TextFormField(
                controller: _marcaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  icon: Icon(Icons.branding_watermark),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Introduce la marca' : null,
              ),
              TextFormField(
                controller: _modeloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  icon: Icon(Icons.model_training),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Introduce el modelo' : null,
              ),
              TextFormField(
                controller: _kmCtrl,
                decoration: const InputDecoration(
                  labelText: 'Kilómetros Actuales',
                  icon: Icon(Icons.speed),
                ),
                keyboardType: TextInputType.number,
                // ESTO ES NUEVO: Bloquea letras en el teclado
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Introduce los km';
                  if (int.tryParse(value) == null) return 'Número no válido';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _combustible,
                decoration: const InputDecoration(
                  labelText: 'Combustible',
                  icon: Icon(Icons.gas_meter),
                ),
                items: ['Gasolina', 'Diesel', 'Híbrido', 'Eléctrico'].map((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) =>
                    setState(() => _combustible = newValue!),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _guardarVehiculo,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Guardar Vehículo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _guardarVehiculo() {
    if (_formKey.currentState!.validate()) {
      final nuevoCoche = Vehiculo(
        matricula: _matriculaCtrl.text,
        marca: _marcaCtrl.text,
        modelo: _modeloCtrl.text,
        numeroBastidor: '',
        combustible: _combustible,
        kilometrosActuales: int.tryParse(_kmCtrl.text) ?? 0,
      );

      // DEVOLVEMOS EL COCHE: Al cerrar, mandamos el objeto de vuelta
      Navigator.pop(context, nuevoCoche);
    }
  }
}
