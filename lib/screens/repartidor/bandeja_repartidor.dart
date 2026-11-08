import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../models/estado_pedido.dart';
import '../../models/pedido.dart';
import '../../repositories/entrega_repository.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../pedidos/mis_pedidos_screen.dart' show etiquetaEstado;

class BandejaRepartidor extends StatefulWidget {
  final String repartidorUid;
  final String nombre;
  final EntregaRepository entregaRepository;

  const BandejaRepartidor({
    super.key,
    required this.repartidorUid,
    required this.nombre,
    required this.entregaRepository,
  });

  @override
  State<BandejaRepartidor> createState() => _BandejaRepartidorState();
}

class _BandejaRepartidorState extends State<BandejaRepartidor> {
  late Stream<List<Pedido>> _pedidos = _observar();

  Stream<List<Pedido>> _observar() =>
      widget.entregaRepository.observarAsignados(widget.repartidorUid);

  void _reintentar() => setState(() => _pedidos = _observar());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Pedido>>(
      stream: _pedidos,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorView(
            mensaje: 'No se pudieron cargar tus entregas.',
            onReintentar: _reintentar,
          );
        }
        final pedidos = snapshot.data;
        if (pedidos == null) return const LoadingView();
        if (pedidos.isEmpty) {
          return EmptyView(
            icono: Icons.delivery_dining,
            mensaje: 'Hola, ${widget.nombre}. No tienes pedidos asignados.',
          );
        }

        final enCurso = pedidos
            .where((pedido) => pedido.estado == EstadoPedido.enCamino)
            .toList();
        final asignados = pedidos
            .where((pedido) => pedido.estado == EstadoPedido.listo)
            .toList();

        return ListView(
          padding: EdgeInsets.fromLTRB(
            12,
            12,
            12,
            12 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            if (enCurso.isNotEmpty) ...[
              const _Titulo('En curso'),
              for (final pedido in enCurso) _EntregaCard(pedido: pedido),
            ],
            if (asignados.isNotEmpty) ...[
              const _Titulo('Asignados'),
              for (final pedido in asignados) _EntregaCard(pedido: pedido),
            ],
          ],
        );
      },
    );
  }
}

class _Titulo extends StatelessWidget {
  final String texto;

  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _EntregaCard extends StatelessWidget {
  final Pedido pedido;

  const _EntregaCard({required this.pedido});

  @override
  Widget build(BuildContext context) {
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
            Text('Total: ${formatearPrecio(pedido.total)}'),
            Text(pedido.direccion),
          ],
        ),
      ),
    );
  }
}
