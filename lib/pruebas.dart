// ignore_for_file: avoid_print
class Vehiculo {
  String matricula;
  String marca;
  String modelo;
  String combustible;
  String tipo;
  String numeroBastidor;
  int kilometraje;

  Vehiculo({
    required this.matricula,
    required this.marca,
    required this.modelo,
    required this.combustible,
    required this.tipo,
    required this.numeroBastidor,
    required this.kilometraje,
  });

  void cambiarMatricula(String matricula) {
    this.matricula = matricula;
    print('La matrícula del vehículo $modelo ha sido cambiada a $matricula.');
  }
}

void main() {
  List<Vehiculo> misCoches = [
    Vehiculo(
      marca: 'Peugeot',
      modelo: '508',
      matricula: '5757JPT',
      combustible: 'Diesel',
      tipo: 'Berlina',
      numeroBastidor: '000022515',
      kilometraje: 170000,
    ),
    Vehiculo(
      marca: 'Hyundai',
      modelo: 'Bayon',
      matricula: '9055LYT',
      combustible: 'Gasolina',
      tipo: 'SUV',
      numeroBastidor: '000022516',
      kilometraje: 25000,
    ),
  ];

  imprimirMarcas(misCoches);
}

void imprimirMarcas(List<Vehiculo> lista) {
    // Prueba eliminada
  for (var coche in lista) {
    if (coche.kilometraje < 50000) {
      print('Vehículo encontrado: ${coche.marca} ${coche.modelo}');
    }
  }
}
