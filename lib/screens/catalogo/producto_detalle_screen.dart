import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../models/linea_pedido.dart';
import '../../models/producto.dart';
import '../../widgets/selector_cantidad.dart';

class ProductoDetalleScreen extends StatefulWidget {
  final Producto producto;

  final ValueChanged<LineaPedido>? onAgregar;

  const ProductoDetalleScreen({
    super.key,
    required this.producto,
    this.onAgregar,
  });

  @override
  State<ProductoDetalleScreen> createState() => _ProductoDetalleScreenState();
}

class _ProductoDetalleScreenState extends State<ProductoDetalleScreen> {
  int _cantidad = 1;

  void _agregar() {
    final producto = widget.producto;
    widget.onAgregar!(
      LineaPedido(
        productoId: producto.id,
        nombreProducto: producto.nombre,
        cantidad: _cantidad,
        precioUnitario: producto.precioReferencia,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(producto.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.fastfood, size: 72, color: colors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              producto.nombre,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(producto.categoria),
              backgroundColor: colors.secondaryContainer,
              side: BorderSide.none,
            ),
            const SizedBox(height: 8),
            Text(
              formatearPrecio(producto.precioReferencia),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('Precio de referencia'),
            const Divider(height: 32),
            Text(producto.descripcion),
          ],
        ),
      ),
      bottomNavigationBar: widget.onAgregar == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SelectorCantidad(
                      cantidad: _cantidad,
                      onCambiar: (cantidad) =>
                          setState(() => _cantidad = cantidad),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _agregar,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Agregar al carrito'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
