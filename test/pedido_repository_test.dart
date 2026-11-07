import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedidos_entregas/core/errores.dart';
import 'package:pedidos_entregas/local/app_database.dart';
import 'package:pedidos_entregas/local/pedido_local_data_source.dart';
import 'package:pedidos_entregas/models/estado_pedido.dart';
import 'package:pedidos_entregas/models/estado_sync.dart';
import 'package:pedidos_entregas/models/linea_pedido.dart';
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

void main() {
  late AppDatabase db;
  late PedidoLocalDataSource local;
  late PedidoRepositoryImpl repositorio;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    local = PedidoLocalDataSource(db);
    repositorio = PedidoRepositoryImpl(local: local);
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
}
