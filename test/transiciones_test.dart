import 'package:flutter_test/flutter_test.dart';
import 'package:pedidos_entregas/core/errores.dart';
import 'package:pedidos_entregas/models/estado_pedido.dart';
import 'package:pedidos_entregas/models/estado_sync.dart';
import 'package:pedidos_entregas/models/pedido.dart';
import 'package:pedidos_entregas/models/transiciones.dart';

Pedido en(EstadoPedido estado, {String? repartidorUid}) => Pedido(
  id: 'a',
  clienteUid: 'cliente-1',
  lineas: const [],
  direccion: 'Calle 1',
  estado: estado,
  repartidorUid: repartidorUid,
  createdAt: DateTime(2026, 11, 8),
  updatedAt: DateTime(2026, 11, 8),
  estadoSync: EstadoSync.sincronizado,
);

final rechazo = throwsA(isA<ReglaDeNegocioException>());

void main() {
  group('validarTransicion', () {
    test('acepta el flujo completo del pedido', () {
      const flujo = [
        EstadoPedido.creado,
        EstadoPedido.confirmado,
        EstadoPedido.preparando,
        EstadoPedido.listo,
        EstadoPedido.enCamino,
        EstadoPedido.entregado,
      ];
      for (var i = 0; i < flujo.length - 1; i++) {
        validarTransicion(en(flujo[i]), flujo[i + 1]);
      }
    });

    test('solo se cancela o rechaza en CREADO', () {
      validarTransicion(en(EstadoPedido.creado), EstadoPedido.cancelado);
      validarTransicion(en(EstadoPedido.creado), EstadoPedido.rechazado);
      for (final estado in EstadoPedido.values) {
        if (estado == EstadoPedido.creado) continue;
        expect(
          () => validarTransicion(en(estado), EstadoPedido.cancelado),
          rechazo,
        );
      }
    });

    test('no se salta pasos ni retrocede', () {
      expect(
        () =>
            validarTransicion(en(EstadoPedido.confirmado), EstadoPedido.listo),
        rechazo,
      );
      expect(
        () =>
            validarTransicion(en(EstadoPedido.listo), EstadoPedido.preparando),
        rechazo,
      );
      expect(
        () =>
            validarTransicion(en(EstadoPedido.creado), EstadoPedido.preparando),
        rechazo,
      );
    });

    test('un estado terminal no se reactiva', () {
      for (final terminal in EstadoPedido.values.where((e) => e.esTerminal)) {
        for (final hacia in EstadoPedido.values) {
          expect(() => validarTransicion(en(terminal), hacia), rechazo);
        }
      }
    });
  });

  group('validarAsignacion', () {
    test('asigna y reasigna mientras está LISTO', () {
      validarAsignacion(en(EstadoPedido.listo));
      validarAsignacion(en(EstadoPedido.listo, repartidorUid: 'r1'));
    });

    test('fuera de LISTO se rechaza', () {
      for (final estado in EstadoPedido.values) {
        if (estado == EstadoPedido.listo) continue;
        expect(() => validarAsignacion(en(estado)), rechazo);
      }
    });
  });
}
