import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../models/estado_pedido.dart';
import '../../models/estado_sync.dart';
import '../../models/pedido.dart';
import '../../repositories/pedido_repository.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/loading_view.dart';

class MisPedidosScreen extends StatefulWidget {
  final PedidoRepository pedidoRepository;
  final String clienteUid;

  const MisPedidosScreen({
    super.key,
    required this.pedidoRepository,
    required this.clienteUid,
  });

  @override
  State<MisPedidosScreen> createState() => _MisPedidosScreenState();
}

class _MisPedidosScreenState extends State<MisPedidosScreen> {
  late final Stream<List<Pedido>> _pedidos = widget.pedidoRepository
      .observarMisPedidos(widget.clienteUid);
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _sincronizar(avisar: false);
  }

  Future<void> _sincronizar({required bool avisar}) async {
    setState(() => _sincronizando = true);
    String mensaje;
    try {
      final resultado = await widget.pedidoRepository.sincronizarPendientes(
        widget.clienteUid,
      );
      mensaje = resultado.pendientes == 0 && resultado.rechazados == 0
          ? 'Todos tus pedidos están enviados.'
          : 'Enviados: ${resultado.sincronizados}. '
                'Pendientes: ${resultado.pendientes}. '
                'Rechazados: ${resultado.rechazados}.';
    } catch (_) {
      mensaje = 'No se pudo sincronizar. Intenta de nuevo.';
    }
    if (!mounted) return;
    setState(() => _sincronizando = false);
    if (avisar) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis pedidos'),
        actions: [
          IconButton(
            tooltip: 'Sincronizar',
            onPressed: _sincronizando ? null : () => _sincronizar(avisar: true),
            icon: _sincronizando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      body: StreamBuilder<List<Pedido>>(
        stream: _pedidos,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const EmptyView(
              icono: Icons.error_outline,
              mensaje: 'No se pudieron leer tus pedidos.',
            );
          }
          final pedidos = snapshot.data;
          if (pedidos == null) return const LoadingView();
          if (pedidos.isEmpty) {
            return const EmptyView(
              icono: Icons.receipt_long_outlined,
              mensaje: 'Aún no tienes pedidos.',
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(
              12,
              12,
              12,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            itemCount: pedidos.length,
            itemBuilder: (context, indice) => _PedidoCard(
              pedido: pedidos[indice],
              onDescartar: () => widget.pedidoRepository.descartarRechazado(
                pedidos[indice].id,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onDescartar;

  const _PedidoCard({required this.pedido, required this.onDescartar});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (textoSync, iconoSync, colorSync) = switch (pedido.estadoSync) {
      EstadoSync.pendiente => (
        'Pendiente de envío',
        Icons.cloud_upload_outlined,
        colors.tertiaryContainer,
      ),
      EstadoSync.sincronizado => (
        'Enviado',
        Icons.cloud_done_outlined,
        colors.secondaryContainer,
      ),
      EstadoSync.rechazado => (
        'Rechazado por el servidor',
        Icons.cloud_off_outlined,
        colors.errorContainer,
      ),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatearFecha(pedido.createdAt),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(etiquetaEstado(pedido.estado)),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            for (final linea in pedido.lineas)
              Text('${linea.cantidad} × ${linea.nombreProducto}'),
            const SizedBox(height: 4),
            Text(
              '${pedido.estadoSync == EstadoSync.sincronizado ? 'Total' : 'Total estimado'}: '
              '${formatearPrecio(pedido.total)}',
            ),
            Text(pedido.direccion),
            if (pedido.codigoRecepcion != null)
              Text(
                'Código de recepción: ${pedido.codigoRecepcion}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  avatar: Icon(iconoSync, size: 18),
                  label: Text(textoSync),
                  backgroundColor: colorSync,
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                ),
                if (pedido.estadoSync == EstadoSync.rechazado)
                  TextButton(
                    onPressed: onDescartar,
                    child: const Text('Descartar'),
                  ),
              ],
            ),
            if (pedido.lastError != null &&
                pedido.estadoSync != EstadoSync.sincronizado)
              Text(pedido.lastError!, style: TextStyle(color: colors.error)),
          ],
        ),
      ),
    );
  }
}

String etiquetaEstado(EstadoPedido estado) => switch (estado) {
  EstadoPedido.creado => 'Creado',
  EstadoPedido.confirmado => 'Confirmado',
  EstadoPedido.preparando => 'Preparando',
  EstadoPedido.listo => 'Listo',
  EstadoPedido.enCamino => 'En camino',
  EstadoPedido.entregado => 'Entregado',
  EstadoPedido.rechazado => 'Rechazado',
  EstadoPedido.cancelado => 'Cancelado',
};
