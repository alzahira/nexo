import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/usuario_provider.dart';
import '../../models/gestion/item_compra.dart';
import 'add_item_compra_screen.dart';
import '../theme/app_theme.dart';

class ListaCompraScreen extends StatefulWidget {
  const ListaCompraScreen({super.key});

  @override
  State<ListaCompraScreen> createState() => _ListaCompraScreenState();
}

class _ListaCompraScreenState extends State<ListaCompraScreen> {
  void _addItem() async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddItemCompraScreen()));
    if (res is ItemCompra && mounted) {
      context.read<UsuarioProvider>().addItemCompra(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = context.watch<UsuarioProvider>().listaCompra;
    final pendientes = items.where((i) => !i.estaComprado).toList();
    final comprados = items.where((i) => i.estaComprado).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Lista de la Compra'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: items.isEmpty
        ? const Center(child: Text('Nada por comprar. ¡Todo listo!', style: TextStyle(color: AppTheme.textSecondary)))
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pendientes.isNotEmpty) ...[
                const Text('PENDIENTES', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                const Divider(),
                ...pendientes.map((i) => _itemRow(i)),
              ],
              if (comprados.isNotEmpty) ...[
                const SizedBox(height: 25),
                const Text('COMPRADOS', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                const Divider(),
                ...comprados.map((i) => _itemRow(i)),
              ],
            ],
          ),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.green, foregroundColor: Colors.white, onPressed: _addItem, child: const Icon(Icons.add_shopping_cart)),
    );
  }

  Widget _itemRow(ItemCompra item) {
    return ListTile(
      leading: Checkbox(
        value: item.estaComprado,
        activeColor: Colors.green,
        onChanged: (v) {
          setState(() {
            item.estaComprado = v!;
            context.read<UsuarioProvider>().notify(guardarGestion: true);
          });
        },
      ),
      title: Text(item.nombre, style: TextStyle(decoration: item.estaComprado ? TextDecoration.lineThrough : null, color: item.estaComprado ? AppTheme.textSecondary : Colors.black)),
      subtitle: Text('${item.cantidad} ${item.unidad}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        onPressed: () => context.read<UsuarioProvider>().removeItemCompra(item),
      ),
    );
  }
}
