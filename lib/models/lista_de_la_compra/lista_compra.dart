import 'item_compra.dart';

class ListaCompra {
  String nombre;
  DateTime fechaCreacion;
  List<ItemCompra> items;

  ListaCompra({
    required this.nombre,
    required this.fechaCreacion,
    this.items = const [],
  });
}