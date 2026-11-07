import 'package:flutter_test/flutter_test.dart';
import 'package:pedidos_entregas/core/errores.dart';
import 'package:pedidos_entregas/models/confirmacion.dart';
import 'package:pedidos_entregas/models/linea_pedido.dart';
import 'package:pedidos_entregas/models/producto.dart';

const hamburguesa = LineaPedido(
  productoId: 'p001',
  nombreProducto: 'Hamburguesa',
  cantidad: 2,
  precioUnitario: 18000,
);
const brownie = LineaPedido(
  productoId: 'p008',
  nombreProducto: 'Brownie',
  cantidad: 1,
  precioUnitario: 5500,
);

ProductoOperativo operativo(
  String id, {
  required int precio,
  required int stock,
}) => ProductoOperativo(
  id: id,
  nombre: 'Producto $id',
  precio: precio,
  stock: stock,
);

void main() {
  test('recalcula líneas y total con el precio vigente', () {
    final confirmacion = calcularConfirmacion(
      const [hamburguesa, brownie],
      {
        'p001': operativo('p001', precio: 19000, stock: 10),
        'p008': operativo('p008', precio: 6000, stock: 10),
      },
    );

    expect(confirmacion.lineas.map((l) => l.precioUnitario), [19000, 6000]);
    expect(confirmacion.total, 2 * 19000 + 6000);
  });

  test('descuenta el stock de todos los productos', () {
    final confirmacion = calcularConfirmacion(
      const [hamburguesa, brownie],
      {
        'p001': operativo('p001', precio: 18000, stock: 5),
        'p008': operativo('p008', precio: 5500, stock: 3),
      },
    );

    expect(confirmacion.stockRestante, {'p001': 3, 'p008': 2});
  });

  test('el último producto en stock se puede confirmar y queda en cero', () {
    final confirmacion = calcularConfirmacion(
      const [hamburguesa],
      {'p001': operativo('p001', precio: 18000, stock: 2)},
    );

    expect(confirmacion.stockRestante['p001'], 0);
  });

  test('sin stock suficiente lanza el mensaje y no confirma', () {
    expect(
      () => calcularConfirmacion(
        const [brownie, hamburguesa],
        {
          'p001': operativo('p001', precio: 18000, stock: 1),
          'p008': operativo('p008', precio: 5500, stock: 10),
        },
      ),
      throwsA(
        isA<ReglaDeNegocioException>().having(
          (error) => error.mensaje,
          'mensaje',
          contains('No hay stock suficiente'),
        ),
      ),
    );
  });

  test('un producto que ya no existe impide confirmar', () {
    expect(
      () => calcularConfirmacion(const [hamburguesa], {'p001': null}),
      throwsA(isA<ReglaDeNegocioException>()),
    );
  });
}
