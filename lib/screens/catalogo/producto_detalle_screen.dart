import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../models/producto.dart';

class ProductoDetalleScreen extends StatelessWidget {
  final Producto producto;

  const ProductoDetalleScreen({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
