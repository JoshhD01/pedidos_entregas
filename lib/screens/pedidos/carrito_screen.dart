import 'package:flutter/material.dart';

import '../../core/errores.dart';
import '../../core/formato.dart';
import '../../models/linea_pedido.dart';
import '../../models/pedido.dart';
import '../../repositories/pedido_repository.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/selector_cantidad.dart';

class CarritoScreen extends StatefulWidget {
  final ValueNotifier<List<LineaPedido>> carrito;
  final PedidoRepository pedidoRepository;
  final String clienteUid;

  const CarritoScreen({
    super.key,
    required this.carrito,
    required this.pedidoRepository,
    required this.clienteUid,
  });

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final _formulario = GlobalKey<FormState>();
  final _direccion = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    _direccion.dispose();
    super.dispose();
  }

  void _cambiarCantidad(LineaPedido linea, int cantidad) {
    widget.carrito.value = [
      for (final actual in widget.carrito.value)
        if (actual.productoId == linea.productoId)
          LineaPedido(
            productoId: actual.productoId,
            nombreProducto: actual.nombreProducto,
            cantidad: cantidad,
            precioUnitario: actual.precioUnitario,
          )
        else
          actual,
    ];
  }

  void _quitar(LineaPedido linea) {
    widget.carrito.value = widget.carrito.value
        .where((actual) => actual.productoId != linea.productoId)
        .toList();
  }

  Future<void> _crearPedido() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final pedido = await widget.pedidoRepository.crearPedido(
        clienteUid: widget.clienteUid,
        lineas: widget.carrito.value,
        direccion: _direccion.text,
      );
      widget.carrito.value = const [];
      if (mounted) Navigator.pop<Pedido>(context, pedido);
    } catch (error) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is ReglaDeNegocioException
                ? error.mensaje
                : 'No se pudo guardar el pedido.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: ValueListenableBuilder<List<LineaPedido>>(
        valueListenable: widget.carrito,
        builder: (context, lineas, _) {
          if (lineas.isEmpty) {
            return const EmptyView(
              icono: Icons.shopping_cart_outlined,
              mensaje: 'Tu carrito está vacío. Agrega productos del catálogo.',
            );
          }
          final total = lineas.fold(0, (suma, linea) => suma + linea.subtotal);

          return Form(
            key: _formulario,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                for (final linea in lineas)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  linea.nombreProducto,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${formatearPrecio(linea.precioUnitario)} c/u',
                                ),
                                Text(formatearPrecio(linea.subtotal)),
                              ],
                            ),
                          ),
                          SelectorCantidad(
                            cantidad: linea.cantidad,
                            onCambiar: _guardando
                                ? (_) {}
                                : (cantidad) =>
                                      _cambiarCantidad(linea, cantidad),
                          ),
                          IconButton(
                            tooltip: 'Quitar del carrito',
                            onPressed: _guardando ? null : () => _quitar(linea),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  ),
                Text(
                  'Total estimado: ${formatearPrecio(total)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Calculado con precios de referencia. El total final se '
                  'confirma con los precios vigentes.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _direccion,
                  enabled: !_guardando,
                  decoration: const InputDecoration(
                    labelText: 'Dirección de entrega',
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) => (valor ?? '').trim().isEmpty
                      ? 'Indica la dirección de entrega.'
                      : null,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _guardando ? null : _crearPedido,
                  child: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Crear pedido'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
