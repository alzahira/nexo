import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/gestion/item_compra.dart';
import '../../providers/auth_provider.dart';
import '../../providers/compra_sync_provider.dart';
import '../../providers/usuario_provider.dart';
import '../theme/app_theme.dart';
import 'add_item_compra_screen.dart';

/// Lista de la compra compartida por la familia.
///
/// Se guarda en Firestore (para todos los miembros) y se sincroniza con una
/// lista de Google Tasks, que además se puede ver desde Google Calendar.
class ListaCompraScreen extends StatefulWidget {
  const ListaCompraScreen({super.key});

  @override
  State<ListaCompraScreen> createState() => _ListaCompraScreenState();
}

class _ListaCompraScreenState extends State<ListaCompraScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      // Solo se sincroniza solo si ya hay sesión de Google en esta sesión;
      // si no, se muestra el botón Conectar.
      if ((auth.googleAccessToken ?? '').isNotEmpty) {
        _sincronizar(silencioso: true);
      }
    });
  }

  Future<void> _sincronizar({bool silencioso = false}) async {
    final compra = context.read<CompraSyncProvider>();
    final usuario = context.read<UsuarioProvider>();
    await compra.sincronizar(usuario);
    if (!mounted || silencioso) return;

    final error = compra.error;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    if (error != null) {
      messenger.showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: AppTheme.dangerRed,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 8),
      ));
      return;
    }
    messenger.showSnackBar(SnackBar(
      content: Text(
        'Lista sincronizada · ↑ ${compra.ultimosSubidos} enviados · '
        '↓ ${compra.ultimosImportados} recibidos',
      ),
      backgroundColor: AppTheme.accent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _conectar() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginConGoogle();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.errorMessage ?? 'No se pudo conectar con Google.'),
        backgroundColor: AppTheme.dangerRed,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    await _sincronizar();
  }

  Future<void> _addItem() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddItemCompraScreen()),
    );
    if (res is ItemCompra && mounted) {
      await context.read<UsuarioProvider>().addItemCompra(res);
      if (!mounted) return;
      await _sincronizar(silencioso: true);
    }
  }

  Future<void> _toggle(ItemCompra item) async {
    final usuario = context.read<UsuarioProvider>();
    final index = usuario.listaCompra.indexOf(item);
    if (index < 0) return;
    usuario.toggleItemCompra(index);
    await _sincronizar(silencioso: true);
  }

  Future<void> _borrar(ItemCompra item) async {
    final compra = context.read<CompraSyncProvider>();
    final usuario = context.read<UsuarioProvider>();
    await compra.eliminarProducto(usuario, item);
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<UsuarioProvider>();
    final compra = context.watch<CompraSyncProvider>();
    final items = usuario.listaCompra;
    final pendientes = items.where((i) => !i.estaComprado).toList();
    final comprados = items.where((i) => i.estaComprado).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Lista de la compra'),
        actions: [
          IconButton(
            tooltip: 'Sincronizar con Google Tasks',
            onPressed: compra.syncing ? null : () => _sincronizar(),
            icon: compra.syncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.accentGlow,
                    ),
                  )
                : const Icon(Icons.sync_rounded, color: AppTheme.accentGlow),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: items.isEmpty
              ? _vacio()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  children: [
                    _barraEstado(compra),
                    if (pendientes.isNotEmpty) ...[
                      _tituloSeccion('PENDIENTES', pendientes.length),
                      ...pendientes.map(_fila),
                    ],
                    if (comprados.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      _tituloSeccion('EN LA CESTA', comprados.length),
                      ...comprados.map(_fila),
                    ],
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Añadir',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _vacio() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              color: AppTheme.softMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_basket_rounded,
                size: 42, color: AppTheme.accent),
          ),
          const SizedBox(height: 18),
          const Text(
            'Nada por comprar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Añade lo que falte y aparecerá también en Google Tasks y en '
            'Google Calendar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tituloSeccion(String texto, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 10),
      child: Row(
        children: [
          Text(
            texto,
            style: const TextStyle(
              fontSize: 11.5,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: AppTheme.softSand,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$total',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barraEstado(CompraSyncProvider compra) {
    if (compra.error != null) {
      final sinPermiso = compra.sinPermiso;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
        decoration: BoxDecoration(
          color: AppTheme.softPeach,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              sinPermiso ? Icons.cloud_off_rounded : Icons.error_outline_rounded,
              size: 18,
              color: sinPermiso ? AppTheme.textSecondary : AppTheme.dangerRed,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                compra.error!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: sinPermiso
                  ? _conectar
                  : () => _sincronizar(),
              child: Text(
                sinPermiso ? 'Conectar' : 'Reintentar',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    if (compra.lastSync != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            const Icon(Icons.cloud_done_rounded,
                size: 16, color: AppTheme.accent),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Google Tasks · '
                '${DateFormat('HH:mm').format(compra.lastSync!)} · '
                '↑ ${compra.ultimosSubidos} · ↓ ${compra.ultimosImportados}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.cloud_queue_rounded,
              size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Conecta Google para ver la lista en Tasks y Calendar',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: _conectar,
            child: const Text(
              'Conectar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fila(ItemCompra item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: InkResponse(
          onTap: () => _toggle(item),
          radius: 22,
          child: Icon(
            item.estaComprado
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 26,
            color: item.estaComprado ? AppTheme.accent : AppTheme.borderColor,
          ),
        ),
        title: Text(
          item.nombre,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: item.estaComprado
                ? AppTheme.textSecondary
                : AppTheme.textPrimary,
            decoration:
                item.estaComprado ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          item.cantidadTexto,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: IconButton(
          tooltip: 'Quitar de la lista',
          icon: const Icon(Icons.delete_outline_rounded,
              color: AppTheme.dangerRed, size: 20),
          onPressed: () => _borrar(item),
        ),
      ),
    );
  }
}
