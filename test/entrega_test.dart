import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedidos_entregas/models/estado_pedido.dart';
import 'package:pedidos_entregas/models/estado_sync.dart';
import 'package:pedidos_entregas/models/linea_pedido.dart';
import 'package:pedidos_entregas/models/pedido.dart';
import 'package:pedidos_entregas/remote/entrega_remote_data_source.dart';
import 'package:pedidos_entregas/repositories/entrega_repository.dart';
import 'package:pedidos_entregas/screens/repartidor/bandeja_repartidor.dart';

Map<String, dynamic> documento(String estado, DateTime creado) => {
  'clienteUid': 'cliente-1',
  'lineas': [
    {
      'productoId': 'p001',
      'nombreProducto': 'Hamburguesa',
      'cantidad': 2,
      'precioUnitario': 18000,
    },
  ],
  'total': 36000,
  'direccion': 'Calle 1',
  'estado': estado,
  'repartidorUid': 'repartidor-1',
  'createdAt': Timestamp.fromDate(creado),
  'updatedAt': Timestamp.fromDate(creado),
};

Pedido pedido(String id, EstadoPedido estado) => Pedido(
  id: id,
  clienteUid: 'cliente-1',
  lineas: [
    LineaPedido(
      productoId: 'p001',
      nombreProducto: 'Hamburguesa $id',
      cantidad: 1,
      precioUnitario: 18000,
    ),
  ],
  direccion: 'Calle $id',
  estado: estado,
  repartidorUid: 'repartidor-1',
  createdAt: DateTime(2026, 11, 7, 10),
  updatedAt: DateTime(2026, 11, 7, 10),
  estadoSync: EstadoSync.sincronizado,
);

class FakeEntregaRepository implements EntregaRepository {
  var controlador = StreamController<List<Pedido>>();
  final pedidos = <String>[];

  @override
  Stream<List<Pedido>> observarAsignados(String repartidorUid) {
    pedidos.add(repartidorUid);
    controlador = StreamController<List<Pedido>>();
    return controlador.stream;
  }
}

Widget bandeja(FakeEntregaRepository repo) => MaterialApp(
  home: Scaffold(
    body: BandejaRepartidor(
      repartidorUid: 'repartidor-1',
      nombre: 'Repartidor',
      entregaRepository: repo,
    ),
  ),
);

void main() {
  group('pedidosValidos', () {
    test('ordena por fecha de creación', () {
      final pedidos = pedidosValidos({
        'b': documento('EN_CAMINO', DateTime(2026, 11, 7, 12)),
        'a': documento('LISTO', DateTime(2026, 11, 7, 9)),
      });

      expect(pedidos.map((p) => p.id), ['a', 'b']);
    });

    test('omite documentos con formato inválido sin fallar', () {
      final pedidos = pedidosValidos({
        'bueno': documento('LISTO', DateTime(2026, 11, 7)),
        'sin-lineas': documento('LISTO', DateTime(2026, 11, 7))
          ..remove('lineas'),
        'estado-raro': documento('PERDIDO', DateTime(2026, 11, 7)),
      });

      expect(pedidos.map((p) => p.id), ['bueno']);
    });
  });

  group('bandeja del repartidor', () {
    testWidgets('consulta solo los pedidos de su uid', (tester) async {
      final repo = FakeEntregaRepository();
      await tester.pumpWidget(bandeja(repo));

      expect(repo.pedidos, ['repartidor-1']);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('separa en curso y asignados', (tester) async {
      final repo = FakeEntregaRepository();
      await tester.pumpWidget(bandeja(repo));
      repo.controlador.add([
        pedido('1', EstadoPedido.listo),
        pedido('2', EstadoPedido.enCamino),
      ]);
      await tester.pump();

      expect(find.text('En curso'), findsOneWidget);
      expect(find.text('Asignados'), findsOneWidget);
      expect(find.text('1 × Hamburguesa 2'), findsOneWidget);
      expect(find.text('1 × Hamburguesa 1'), findsOneWidget);
      final enCurso = tester.getTopLeft(find.text('En curso')).dy;
      final asignados = tester.getTopLeft(find.text('Asignados')).dy;
      expect(enCurso, lessThan(asignados));
    });

    testWidgets('sin pedidos muestra el mensaje vacío', (tester) async {
      final repo = FakeEntregaRepository();
      await tester.pumpWidget(bandeja(repo));
      repo.controlador.add(const []);
      await tester.pump();

      expect(
        find.textContaining('No tienes pedidos asignados'),
        findsOneWidget,
      );
    });

    testWidgets('un error permite reintentar sin mostrar el detalle técnico', (
      tester,
    ) async {
      final repo = FakeEntregaRepository();
      await tester.pumpWidget(bandeja(repo));
      repo.controlador.addError(Exception('permission-denied'));
      await tester.pump();

      expect(find.text('No se pudieron cargar tus entregas.'), findsOneWidget);
      expect(find.textContaining('permission-denied'), findsNothing);

      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      expect(repo.pedidos, hasLength(2));
    });
  });
}
