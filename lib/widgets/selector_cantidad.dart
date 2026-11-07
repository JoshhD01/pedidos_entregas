import 'package:flutter/material.dart';

import '../repositories/pedido_repository.dart';

class SelectorCantidad extends StatelessWidget {
  final int cantidad;
  final ValueChanged<int> onCambiar;

  const SelectorCantidad({
    super.key,
    required this.cantidad,
    required this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Quitar uno',
          onPressed: cantidad > 1 ? () => onCambiar(cantidad - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$cantidad', style: const TextStyle(fontSize: 18)),
        IconButton(
          tooltip: 'Agregar uno',
          onPressed: cantidad < PedidoRepositoryImpl.maxCantidad
              ? () => onCambiar(cantidad + 1)
              : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
