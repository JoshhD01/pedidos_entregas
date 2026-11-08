import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedidos_entregas/core/errores.dart';
import 'package:pedidos_entregas/models/entrega.dart';
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
  final iniciados = <String>[];
  final entregas = <(String, String)>[];
  Completer<void>? espera;
  Object? error;

  @override
  Future<void> iniciarRecorrido(String pedidoId, String repartidorUid) async {
    iniciados.add(pedidoId);
    await espera?.future;
    if (error != null) throw error!;
  }

  @override
  Future<void> entregar(
    String pedidoId,
    String repartidorUid,
    String codigo,
  ) async {
    entregas.add((pedidoId, codigo));
    await espera?.future;
    if (error != null) throw error!;
  }

  @override
  Stream<List<Pedido>> observarAsignados(String repartidorUid) {
    pedidos.add(repartidorUid);
    controlador = StreamController<List<Pedido>>();
    return controlador.stream;
  }
}

class FakeRemote implements EntregaRemoteDataSource {
  Completer<void> respuesta = Completer<void>();
  final llamadas = <(String, String)>[];

  @override
  Future<void> iniciarRecorrido(String pedidoId, String repartidorUid) {
    llamadas.add((pedidoId, repartidorUid));
    return respuesta.future;
  }

  @override
  Future<void> entregar(String pedidoId, String repartidorUid, String codigo) {
    llamadas.add((pedidoId, codigo));
    return respuesta.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

  group('validarInicioRecorrido', () {
    test('permite un pedido LISTO asignado sin otro en camino', () {
      validarInicioRecorrido(
        pedido('1', EstadoPedido.listo),
        'repartidor-1',
        null,
      );
    });

    test('rechaza un pedido asignado a otro repartidor', () {
      expect(
        () => validarInicioRecorrido(
          pedido('1', EstadoPedido.listo),
          'otro',
          null,
        ),
        throwsA(isA<ReglaDeNegocioException>()),
      );
    });

    test('rechaza un pedido que no está LISTO', () {
      for (final estado in EstadoPedido.values) {
        if (estado == EstadoPedido.listo) continue;
        expect(
          () =>
              validarInicioRecorrido(pedido('1', estado), 'repartidor-1', null),
          throwsA(isA<ReglaDeNegocioException>()),
          reason: estado.valor,
        );
      }
    });

    test('rechaza un segundo pedido en camino', () {
      expect(
        () => validarInicioRecorrido(
          pedido('2', EstadoPedido.listo),
          'repartidor-1',
          '1',
        ),
        throwsA(
          isA<ReglaDeNegocioException>().having(
            (e) => e.mensaje,
            'mensaje',
            contains('Ya tienes un pedido en camino'),
          ),
        ),
      );
    });
  });

  group('EntregaRepositoryImpl.iniciarRecorrido', () {
    test('envía el pedido y el uid del repartidor', () async {
      final remote = FakeRemote()..respuesta.complete();
      await EntregaRepositoryImpl(
        remote: remote,
      ).iniciarRecorrido('p-1', 'repartidor-1');

      expect(remote.llamadas, [('p-1', 'repartidor-1')]);
    });

    test('sin red termina con TimeoutException', () async {
      final repo = EntregaRepositoryImpl(
        remote: FakeRemote(),
        tiempoLimite: const Duration(milliseconds: 10),
      );

      expect(
        repo.iniciarRecorrido('p-1', 'repartidor-1'),
        throwsA(isA<TimeoutException>()),
      );
    });
  });

  group('iniciar recorrido en la bandeja', () {
    Future<FakeEntregaRepository> abrirConListo(WidgetTester tester) async {
      final repo = FakeEntregaRepository();
      await tester.pumpWidget(bandeja(repo));
      repo.controlador.add([pedido('1', EstadoPedido.listo)]);
      await tester.pump();
      return repo;
    }

    testWidgets('solo los asignados tienen el botón', (tester) async {
      final repo = FakeEntregaRepository();
      await tester.pumpWidget(bandeja(repo));
      repo.controlador.add([
        pedido('1', EstadoPedido.listo),
        pedido('2', EstadoPedido.enCamino),
      ]);
      await tester.pump();

      expect(find.text('Iniciar recorrido'), findsOneWidget);
    });

    testWidgets('bloquea el botón mientras guarda y avisa el resultado', (
      tester,
    ) async {
      final repo = await abrirConListo(tester);
      repo.espera = Completer<void>();

      await tester.tap(find.text('Iniciar recorrido'));
      await tester.pump();
      expect(find.text('Guardando...'), findsOneWidget);
      await tester.tap(find.text('Guardando...'));
      expect(repo.iniciados, ['1']);

      repo.espera!.complete();
      await tester.pump();
      expect(find.text('Recorrido iniciado.'), findsOneWidget);
      expect(find.text('Iniciar recorrido'), findsOneWidget);
    });

    testWidgets('muestra la regla de negocio que impidió iniciar', (
      tester,
    ) async {
      final repo = await abrirConListo(tester);
      repo.error = const ReglaDeNegocioException(
        'Ya tienes un pedido en camino. Entrégalo antes de iniciar otro.',
      );

      await tester.tap(find.text('Iniciar recorrido'));
      await tester.pump();

      expect(
        find.textContaining('Ya tienes un pedido en camino'),
        findsOneWidget,
      );
    });

    testWidgets('un error inesperado no muestra detalles técnicos', (
      tester,
    ) async {
      final repo = await abrirConListo(tester);
      repo.error = Exception('permission-denied');

      await tester.tap(find.text('Iniciar recorrido'));
      await tester.pump();

      expect(find.text('No se pudo actualizar el pedido.'), findsOneWidget);
      expect(find.textContaining('permission-denied'), findsNothing);
    });
  });

  group('validarEntrega y validarCodigo', () {
    test('permite entregar un pedido EN_CAMINO asignado', () {
      validarEntrega(pedido('1', EstadoPedido.enCamino), 'repartidor-1');
    });

    test('rechaza un pedido de otro repartidor', () {
      expect(
        () => validarEntrega(pedido('1', EstadoPedido.enCamino), 'otro'),
        throwsA(isA<ReglaDeNegocioException>()),
      );
    });

    test('rechaza entregar sin pasar por EN_CAMINO', () {
      for (final estado in EstadoPedido.values) {
        if (estado == EstadoPedido.enCamino) continue;
        expect(
          () => validarEntrega(pedido('1', estado), 'repartidor-1'),
          throwsA(isA<ReglaDeNegocioException>()),
          reason: estado.valor,
        );
      }
    });

    test('el código tiene exactamente 6 dígitos', () {
      validarCodigo('012345');
      for (final codigo in ['', '12345', '1234567', '12a456', ' 12345']) {
        expect(
          () => validarCodigo(codigo),
          throwsA(isA<ReglaDeNegocioException>()),
          reason: codigo,
        );
      }
    });
  });

  group('EntregaRepositoryImpl.entregar', () {
    test('envía el código digitado', () async {
      final remote = FakeRemote()..respuesta.complete();
      await EntregaRepositoryImpl(
        remote: remote,
      ).entregar('p-1', 'repartidor-1', '123456');

      expect(remote.llamadas, [('p-1', '123456')]);
    });

    test('un código mal formado no llega a Firestore', () async {
      final remote = FakeRemote();

      await expectLater(
        EntregaRepositoryImpl(
          remote: remote,
        ).entregar('p-1', 'repartidor-1', '12'),
        throwsA(isA<ReglaDeNegocioException>()),
      );
      expect(remote.llamadas, isEmpty);
    });

    test('el rechazo de las reglas se muestra como código incorrecto', () {
      final remote = FakeRemote()
        ..respuesta.completeError(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        );

      expect(
        EntregaRepositoryImpl(
          remote: remote,
        ).entregar('p-1', 'repartidor-1', '123456'),
        throwsA(
          isA<ReglaDeNegocioException>().having(
            (e) => e.mensaje,
            'mensaje',
            'Código incorrecto.',
          ),
        ),
      );
    });

    test('otros errores de Firestore no se confunden con el código', () {
      final remote = FakeRemote()
        ..respuesta.completeError(
          FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
        );

      expect(
        EntregaRepositoryImpl(
          remote: remote,
        ).entregar('p-1', 'repartidor-1', '123456'),
        throwsA(isA<FirebaseException>()),
      );
    });

    test('sin red termina con TimeoutException', () {
      final repo = EntregaRepositoryImpl(
        remote: FakeRemote(),
        tiempoLimite: const Duration(milliseconds: 10),
      );

      expect(
        repo.entregar('p-1', 'repartidor-1', '123456'),
        throwsA(isA<TimeoutException>()),
      );
    });
  });

  group('entregar en la bandeja', () {
    Future<FakeEntregaRepository> abrirEnCamino(WidgetTester tester) async {
      final repo = FakeEntregaRepository();
      await tester.pumpWidget(bandeja(repo));
      repo.controlador.add([pedido('1', EstadoPedido.enCamino)]);
      await tester.pump();
      await tester.tap(find.text('Entregar'));
      await tester.pumpAndSettle();
      return repo;
    }

    testWidgets('un código incompleto no se envía', (tester) async {
      final repo = await abrirEnCamino(tester);

      await tester.enterText(find.byType(TextFormField), '123');
      await tester.tap(find.widgetWithText(FilledButton, 'Entregar').last);
      await tester.pump();

      expect(find.text('El código tiene 6 dígitos.'), findsOneWidget);
      expect(repo.entregas, isEmpty);
    });

    testWidgets('el campo solo acepta dígitos', (tester) async {
      await abrirEnCamino(tester);

      await tester.enterText(find.byType(TextFormField), '12ab34');

      expect(find.text('1234'), findsOneWidget);
    });

    testWidgets('con el código envía la entrega y avisa', (tester) async {
      final repo = await abrirEnCamino(tester);

      await tester.enterText(find.byType(TextFormField), '914190');
      await tester.tap(find.widgetWithText(FilledButton, 'Entregar').last);
      await tester.pumpAndSettle();

      expect(repo.entregas, [('1', '914190')]);
      expect(find.text('Pedido entregado.'), findsOneWidget);
    });

    testWidgets('código incorrecto se muestra al repartidor', (tester) async {
      final repo = await abrirEnCamino(tester);
      repo.error = const ReglaDeNegocioException('Código incorrecto.');

      await tester.enterText(find.byType(TextFormField), '000000');
      await tester.tap(find.widgetWithText(FilledButton, 'Entregar').last);
      await tester.pumpAndSettle();

      expect(find.text('Código incorrecto.'), findsOneWidget);
    });

    testWidgets('cancelar no envía nada', (tester) async {
      final repo = await abrirEnCamino(tester);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(repo.entregas, isEmpty);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
