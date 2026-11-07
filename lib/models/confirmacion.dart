import '../core/errores.dart';
import 'linea_pedido.dart';
import 'producto.dart';

class Confirmacion {
  final List<LineaPedido> lineas;
  final Map<String, int> stockRestante;

  const Confirmacion({required this.lineas, required this.stockRestante});

  int get total => lineas.fold(0, (suma, linea) => suma + linea.subtotal);
}

/// Aplica el precio vigente y descuenta stock; si un producto no alcanza, falla todo.
Confirmacion calcularConfirmacion(
  List<LineaPedido> lineas,
  Map<String, ProductoOperativo?> productos,
) {
  final recalculadas = <LineaPedido>[];
  final stockRestante = <String, int>{};

  for (final linea in lineas) {
    final producto = productos[linea.productoId];
    if (producto == null) {
      throw ReglaDeNegocioException(
        '${linea.nombreProducto} ya no está disponible.',
      );
    }
    if (producto.stock < linea.cantidad) {
      throw ReglaDeNegocioException(
        'No hay stock suficiente de ${producto.nombre} '
        '(disponible: ${producto.stock}).',
      );
    }
    recalculadas.add(
      LineaPedido(
        productoId: linea.productoId,
        nombreProducto: linea.nombreProducto,
        cantidad: linea.cantidad,
        precioUnitario: producto.precio,
      ),
    );
    stockRestante[producto.id] = producto.stock - linea.cantidad;
  }

  return Confirmacion(lineas: recalculadas, stockRestante: stockRestante);
}
