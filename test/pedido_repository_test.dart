import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedidos_entregas/core/errores.dart';
import 'package:pedidos_entregas/local/app_database.dart';
import 'package:pedidos_entregas/local/pedido_local_data_source.dart';
import 'package:pedidos_entregas/models/estado_pedido.dart';
import 'package:pedidos_entregas/models/estado_sync.dart';
import 'package:pedidos_entregas/models/linea_pedido.dart';
import 'package:pedidos_entregas/models/pedido.dart';
import 'package:pedidos_entregas/remote/pedido_remote_data_source.dart';
import 'package:pedidos_entregas/repositories/pedido_repository.dart';

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

LineaPedido linea(String id, {int cantidad = 1}) => LineaPedido(
  productoId: id,
  nombreProducto: 'Producto $id',
  cantidad: cantidad,
  precioUnitario: 1000,
);

Pedido pendiente(String id, {String clienteUid = 'cliente-1'}) => Pedido(
  id: id,
  clienteUid: clienteUid,
  lineas: const [hamburguesa],
  direccion: 'Calle 1',
  estado: EstadoPedido.creado,
  createdAt: DateTime(2026, 11, 5, 10),
  updatedAt: DateTime(2026, 11, 5, 10),
  estadoSync: EstadoSync.pendiente,
  codigoRecepcion: '123456',
);

FirebaseException errorFirestore(String code) =>
    FirebaseException(plugin: 'cloud_firestore', code: code);

/// Sin conexión por defecto.
class FakeRemote implements PedidoRemoteDataSource {
  final documentos = <String, Map<String, dynamic>>{};
  final codigos = <String, String?>{};
  Object? error = errorFirestore('unavailable');
  int intentos = 0;

  Future<void> Function()? duranteEnvio;

  @override
  Future<bool> crearSiNoExiste(Pedido pedido) async {
    intentos++;
    await duranteEnvio?.call();
    if (error != null) throw error!;
    if (documentos.containsKey(pedido.id)) return false;
    documentos[pedido.id] = pedido.toFirestore();
    codigos[pedido.id] = pedido.codigoRecepcion;
    return true;
  }

  final respuestas =
      StreamController<({List<Pedido> pedidos, bool desdeServidor})>();

  @override
  Stream<({List<Pedido> pedidos, bool desdeServidor})> observarDeCliente(
    String clienteUid,
  ) => respuestas.stream;

  /// Igual que la transacción real: relee el estado y valida el dueño.
  @override
  Future<void> cancelar(String pedidoId, String clienteUid) async {
    if (error != null) throw error!;
    final doc = documentos[pedidoId];
    if (doc == null) {
      throw const ReglaDeNegocioException('El pedido no existe.');
    }
    if (doc['clienteUid'] != clienteUid) {
      throw const ReglaDeNegocioException('Este pedido no es tuyo.');
    }
    if (doc['estado'] != EstadoPedido.creado.valor) {
      throw const ReglaDeNegocioException('El pedido ya cambió de estado.');
    }
    doc['estado'] = EstadoPedido.cancelado.valor;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late PedidoLocalDataSource local;
  late FakeRemote remote;
  late PedidoRepositoryImpl repositorio;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    local = PedidoLocalDataSource(db);
    remote = FakeRemote();
    repositorio = PedidoRepositoryImpl(
      local: local,
      remote: remote,
      tiempoLimite: const Duration(milliseconds: 100),
    );
  });

  tearDown(() => db.close());

  test('crear guarda el pedido pendiente con sus líneas y código', () async {
    final creado = await repositorio.crearPedido(
      clienteUid: 'cliente-1',
      lineas: const [hamburguesa, brownie],
      direccion: '  Calle 10 # 20-30  ',
    );

    final guardado =
        (await repositorio.observarMisPedidos('cliente-1').first).single;
    expect(guardado.id, creado.id);
    expect(guardado.estado, EstadoPedido.creado);
    expect(guardado.estadoSync, EstadoSync.pendiente);
    expect(guardado.direccion, 'Calle 10 # 20-30');
    expect(guardado.lineas, hasLength(2));
    expect(guardado.total, 41500);
    expect(guardado.codigoRecepcion, matches(RegExp(r'^\d{6}$')));
    expect(guardado.codigoRecepcion, creado.codigoRecepcion);
  });

  test('cada pedido recibe un id distinto', () async {
    final uno = await repositorio.crearPedido(
      clienteUid: 'cliente-1',
      lineas: const [hamburguesa],
      direccion: 'Calle 1',
    );
    final dos = await repositorio.crearPedido(
      clienteUid: 'cliente-1',
      lineas: const [hamburguesa],
      direccion: 'Calle 1',
    );

    expect(uno.id, isNot(dos.id));
  });

  test('cada cliente solo ve sus pedidos', () async {
    await repositorio.crearPedido(
      clienteUid: 'cliente-1',
      lineas: const [hamburguesa],
      direccion: 'Calle 1',
    );
    await repositorio.crearPedido(
      clienteUid: 'cliente-2',
      lineas: const [brownie],
      direccion: 'Calle 2',
    );

    final mios = await repositorio.observarMisPedidos('cliente-1').first;
    expect(mios.single.lineas.single.productoId, 'p001');
    expect(await local.pendientesDe('cliente-2'), hasLength(1));
  });

  group('reglas del pedido', () {
    Future<void> crear(
      List<LineaPedido> lineas, {
      String direccion = 'Calle 1',
    }) {
      return repositorio.crearPedido(
        clienteUid: 'cliente-1',
        lineas: lineas,
        direccion: direccion,
      );
    }

    test('sin productos se rechaza', () {
      expect(crear(const []), throwsA(isA<ReglaDeNegocioException>()));
    });

    test('más de cinco productos se rechaza', () {
      final seis = [for (var i = 1; i <= 6; i++) linea('p00$i')];
      expect(crear(seis), throwsA(isA<ReglaDeNegocioException>()));
    });

    test('cinco productos se aceptan', () async {
      final cinco = [for (var i = 1; i <= 5; i++) linea('p00$i')];
      await crear(cinco);
      expect(await local.pendientesDe('cliente-1'), hasLength(1));
    });

    test('un producto repetido se rechaza', () {
      expect(
        crear([linea('p001'), linea('p001')]),
        throwsA(isA<ReglaDeNegocioException>()),
      );
    });

    test('cantidades fuera de 1 a 10 se rechazan', () {
      expect(
        crear([linea('p001', cantidad: 0)]),
        throwsA(isA<ReglaDeNegocioException>()),
      );
      expect(
        crear([linea('p001', cantidad: 11)]),
        throwsA(isA<ReglaDeNegocioException>()),
      );
    });

    test('sin dirección se rechaza y no se guarda nada', () async {
      await expectLater(
        crear(const [hamburguesa], direccion: '   '),
        throwsA(isA<ReglaDeNegocioException>()),
      );
      expect(await local.pendientesDe('cliente-1'), isEmpty);
    });
  });

  test('descartar borra solo pedidos rechazados', () async {
    final pendiente = await repositorio.crearPedido(
      clienteUid: 'cliente-1',
      lineas: const [hamburguesa],
      direccion: 'Calle 1',
    );
    final rechazado = await repositorio.crearPedido(
      clienteUid: 'cliente-1',
      lineas: const [brownie],
      direccion: 'Calle 1',
    );
    await local.marcarError(rechazado.id, 'Sin permiso', rechazado: true);

    await repositorio.descartarRechazado(pendiente.id);
    await repositorio.descartarRechazado(rechazado.id);

    final quedan = await repositorio.observarMisPedidos('cliente-1').first;
    expect(quedan.map((p) => p.id), [pendiente.id]);
    final lineas = await db.select(db.lineasPedido).get();
    expect(lineas.map((l) => l.pedidoId), [pendiente.id]);
  });

  group('sincronización', () {
    setUp(() => remote.error = null);

    Future<Pedido> local1(String id) async {
      final guardado = (await local.pendientesDe(
        'cliente-1',
      )).firstWhere((p) => p.id == id);
      return guardado;
    }

    test('envía el pendiente con su código aparte y lo marca', () async {
      await local.insertar(pendiente('a'));

      final resultado = await repositorio.sincronizarPendientes('cliente-1');

      expect(resultado.sincronizados, 1);
      expect(remote.documentos['a']!['estado'], 'CREADO');
      expect(remote.documentos['a']!.containsKey('codigoRecepcion'), isFalse);
      expect(remote.codigos['a'], '123456');
      expect(await local.pendientesDe('cliente-1'), isEmpty);
    });

    test('reintentar no duplica ni sobrescribe el documento', () async {
      await local.insertar(pendiente('a'));
      remote.documentos['a'] = {'estado': 'CONFIRMADO'};

      final resultado = await repositorio.sincronizarPendientes('cliente-1');

      expect(resultado.sincronizados, 1);
      expect(remote.documentos, hasLength(1));
      expect(remote.documentos['a']!['estado'], 'CONFIRMADO');
    });

    test('un fallo temporal deja el pedido pendiente con el error', () async {
      await local.insertar(pendiente('a'));
      remote.error = errorFirestore('unavailable');

      final resultado = await repositorio.sincronizarPendientes('cliente-1');

      expect(resultado.pendientes, 1);
      final pedido = await local1('a');
      expect(pedido.estadoSync, EstadoSync.pendiente);
      expect(pedido.lastError, isNotNull);
    });

    test('sin respuesta a tiempo queda pendiente', () async {
      await local.insertar(pendiente('a'));
      remote.duranteEnvio = () =>
          Future.delayed(const Duration(milliseconds: 300));

      final resultado = await repositorio.sincronizarPendientes('cliente-1');

      expect(resultado.pendientes, 1);
      expect((await local1('a')).lastError, contains('Sin conexión'));
    });

    test('un rechazo del servidor no se vuelve a enviar', () async {
      await local.insertar(pendiente('a'));
      remote.error = errorFirestore('permission-denied');

      final resultado = await repositorio.sincronizarPendientes('cliente-1');
      expect(resultado.rechazados, 1);

      remote.error = null;
      await repositorio.sincronizarPendientes('cliente-1');

      expect(remote.intentos, 1);
      final mios = await repositorio.observarMisPedidos('cliente-1').first;
      expect(mios.single.estadoSync, EstadoSync.rechazado);
    });

    test('una edición durante el envío no se marca sincronizada', () async {
      await local.insertar(pendiente('a'));
      remote.duranteEnvio = () async {
        await (db.update(db.pedidos)..where((p) => p.id.equals('a'))).write(
          PedidosCompanion(updatedAt: Value(DateTime(2026, 11, 5, 11))),
        );
      };

      final resultado = await repositorio.sincronizarPendientes('cliente-1');

      expect(resultado.sincronizados, 0);
      expect((await local1('a')).estadoSync, EstadoSync.pendiente);
    });

    test('solo envía los pedidos del cliente actual', () async {
      await local.insertar(pendiente('a'));
      await local.insertar(pendiente('b', clienteUid: 'cliente-2'));

      await repositorio.sincronizarPendientes('cliente-1');

      expect(remote.documentos.keys, ['a']);
    });

    test('crear el pedido intenta enviarlo sin esperar', () async {
      await repositorio.crearPedido(
        clienteUid: 'cliente-1',
        lineas: const [hamburguesa],
        direccion: 'Calle 1',
      );

      await expectLater(
        repositorio
            .observarMisPedidos('cliente-1')
            .map((pedidos) => pedidos.single.estadoSync),
        emitsThrough(EstadoSync.sincronizado),
      );
      expect(remote.documentos, hasLength(1));
    });

    test('dos envíos simultáneos hacen un solo intento', () async {
      await local.insertar(pendiente('a'));

      final resultados = await Future.wait([
        repositorio.sincronizarPendientes('cliente-1'),
        repositorio.sincronizarPendientes('cliente-1'),
      ]);

      expect(remote.intentos, 1);
      expect(resultados.map((r) => r.pendientes), [0, 0]);
    });
  });

  group('seguimiento', () {
    Pedido remoto(
      String id,
      EstadoPedido estado, {
      String clienteUid = 'cliente-1',
      int precio = 20000,
    }) => Pedido(
      id: id,
      clienteUid: clienteUid,
      lineas: [
        LineaPedido(
          productoId: 'p001',
          nombreProducto: 'Hamburguesa',
          cantidad: 2,
          precioUnitario: precio,
        ),
      ],
      direccion: 'Calle 1',
      estado: estado,
      repartidorUid: estado == EstadoPedido.listo ? 'r1' : null,
      createdAt: DateTime(2026, 11, 5, 10),
      updatedAt: DateTime(2026, 11, 5, 12),
      estadoSync: EstadoSync.sincronizado,
    );

    Future<Pedido> leer(String id) async =>
        (await local.buscar(id, 'cliente-1'))!;

    test('copia estado, repartidor y precio vigente del servidor', () async {
      await local.insertar(pendiente('a'));
      await local.marcarSincronizado('a', DateTime(2026, 11, 5, 10));

      await local.aplicarRemotos('cliente-1', [
        remoto('a', EstadoPedido.listo),
      ]);

      final pedido = await leer('a');
      expect(pedido.estado, EstadoPedido.listo);
      expect(pedido.repartidorUid, 'r1');
      expect(pedido.total, 40000);
      expect(pedido.codigoRecepcion, '123456');
    });

    test('un pendiente en CREADO no se toca', () async {
      await local.insertar(pendiente('a'));

      await local.aplicarRemotos('cliente-1', [
        remoto('a', EstadoPedido.creado),
      ]);

      final pedido = await leer('a');
      expect(pedido.estadoSync, EstadoSync.pendiente);
      expect(pedido.total, 36000);
    });

    test(
      'un pendiente que el servidor ya procesó queda sincronizado',
      () async {
        await local.insertar(pendiente('a'));

        await local.aplicarRemotos('cliente-1', [
          remoto('a', EstadoPedido.confirmado),
        ]);

        final pedido = await leer('a');
        expect(pedido.estado, EstadoPedido.confirmado);
        expect(pedido.estadoSync, EstadoSync.sincronizado);
      },
    );

    test('no toca rechazados ni pedidos de otra cuenta', () async {
      await local.insertar(pendiente('a'));
      await local.marcarError('a', 'Sin permiso', rechazado: true);
      await local.insertar(pendiente('b', clienteUid: 'cliente-2'));
      await local.marcarSincronizado('b', DateTime(2026, 11, 5, 10));

      await local.aplicarRemotos('cliente-1', [
        remoto('a', EstadoPedido.confirmado),
        remoto('b', EstadoPedido.confirmado, clienteUid: 'cliente-2'),
      ]);

      expect((await leer('a')).estadoSync, EstadoSync.rechazado);
      final otro = await local.buscar('b', 'cliente-2');
      expect(otro!.estado, EstadoPedido.creado);
    });

    test('una respuesta del servidor envía los pendientes', () async {
      remote.error = null;
      await local.insertar(pendiente('a'));
      final suscripcion = repositorio
          .seguirMisPedidos('cliente-1')
          .listen(null);
      addTearDown(suscripcion.cancel);

      remote.respuestas.add((pedidos: const [], desdeServidor: false));
      await pumpEventQueue();
      expect(remote.intentos, 0);

      remote.respuestas.add((pedidos: const [], desdeServidor: true));
      await pumpEventQueue();
      expect(remote.intentos, 1);
      expect((await leer('a')).estadoSync, EstadoSync.sincronizado);
    });
  });

  group('cancelar', () {
    setUp(() => remote.error = null);

    test('un pedido CREADO se cancela en el servidor y en local', () async {
      await local.insertar(pendiente('a'));

      await repositorio.cancelarPedido('a', 'cliente-1');

      expect(remote.documentos['a']!['estado'], 'CANCELADO');
      final pedido = (await local.buscar('a', 'cliente-1'))!;
      expect(pedido.estado, EstadoPedido.cancelado);
    });

    test('si el operador ya lo confirmó, gana el operador', () async {
      await local.insertar(pendiente('a'));
      await repositorio.sincronizarPendientes('cliente-1');
      remote.documentos['a']!['estado'] = 'CONFIRMADO';

      await expectLater(
        repositorio.cancelarPedido('a', 'cliente-1'),
        throwsA(isA<ReglaDeNegocioException>()),
      );
      expect(remote.documentos['a']!['estado'], 'CONFIRMADO');
      final pedido = (await local.buscar('a', 'cliente-1'))!;
      expect(pedido.estado, EstadoPedido.creado);
    });

    test('sin conexión no cancela un pedido que no llegó', () async {
      await local.insertar(pendiente('a'));
      remote.error = errorFirestore('unavailable');

      await expectLater(
        repositorio.cancelarPedido('a', 'cliente-1'),
        throwsA(
          isA<ReglaDeNegocioException>().having(
            (e) => e.mensaje,
            'mensaje',
            contains('Sin conexión'),
          ),
        ),
      );
      final pedido = (await local.buscar('a', 'cliente-1'))!;
      expect(pedido.estado, EstadoPedido.creado);
    });

    test('no cancela pedidos de otra cuenta ni ya terminados', () async {
      await local.insertar(pendiente('a', clienteUid: 'cliente-2'));

      await expectLater(
        repositorio.cancelarPedido('a', 'cliente-1'),
        throwsA(isA<ReglaDeNegocioException>()),
      );
      expect(remote.intentos, 0);
    });
  });
}
