import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedidos_entregas/local/app_database.dart';

PedidosCompanion pedido(String id, {String ownerUid = 'cliente1'}) {
  final fecha = DateTime.utc(2026, 11, 4);
  return PedidosCompanion.insert(
    id: id,
    ownerUid: ownerUid,
    direccion: 'Calle 1 # 2-3',
    estado: 'CREADO',
    createdAt: fecha,
    updatedAt: fecha,
  );
}

LineasPedidoCompanion linea(String pedidoId, String productoId) {
  return LineasPedidoCompanion.insert(
    pedidoId: pedidoId,
    productoId: productoId,
    nombreProducto: 'Hamburguesa',
    cantidad: 2,
    precioUnitario: 18000,
  );
}

void main() {
  // La prueba de reapertura abre otra base mientras sigue abierta la de memoria.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('un pedido nuevo queda pendiente de sincronizar', () async {
    await db.into(db.pedidos).insert(pedido('uuid-1'));

    final fila = await db.select(db.pedidos).getSingle();
    expect(fila.estadoSync, 'PENDIENTE');
    expect(fila.codigoRecepcion, isNull);
  });

  test('reintentar con el mismo id no crea otro pedido', () async {
    await db.into(db.pedidos).insert(pedido('uuid-1'));

    await expectLater(
      db.into(db.pedidos).insert(pedido('uuid-1')),
      throwsA(isA<SqliteException>()),
    );
    expect(await db.select(db.pedidos).get(), hasLength(1));
  });

  test('el filtro por ownerUid separa las cuentas', () async {
    await db.into(db.pedidos).insert(pedido('uuid-1', ownerUid: 'cliente1'));
    await db.into(db.pedidos).insert(pedido('uuid-2', ownerUid: 'cliente2'));

    final query = db.select(db.pedidos)
      ..where((t) => t.ownerUid.equals('cliente1'));
    final filas = await query.get();
    expect(filas.map((f) => f.id), ['uuid-1']);
  });

  test('un pedido no repite producto', () async {
    await db.into(db.pedidos).insert(pedido('uuid-1'));
    await db.into(db.lineasPedido).insert(linea('uuid-1', 'p001'));

    await expectLater(
      db.into(db.lineasPedido).insert(linea('uuid-1', 'p001')),
      throwsA(isA<SqliteException>()),
    );
  });

  test('una línea no puede existir sin su pedido', () async {
    await expectLater(
      db.into(db.lineasPedido).insert(linea('no-existe', 'p001')),
      throwsA(isA<SqliteException>()),
    );
  });

  test('borrar un pedido borra sus líneas', () async {
    await db.into(db.pedidos).insert(pedido('uuid-1'));
    await db.into(db.lineasPedido).insert(linea('uuid-1', 'p001'));

    await (db.delete(db.pedidos)..where((t) => t.id.equals('uuid-1'))).go();

    expect(await db.select(db.lineasPedido).get(), isEmpty);
  });

  test('actualizar la copia del catálogo no duplica productos', () async {
    ProductosCacheCompanion producto(int precio) =>
        ProductosCacheCompanion.insert(
          id: 'p001',
          nombre: 'Hamburguesa',
          categoria: 'Comida',
          descripcion: 'Con queso',
          precioReferencia: precio,
        );

    await db.into(db.productosCache).insertOnConflictUpdate(producto(18000));
    await db.into(db.productosCache).insertOnConflictUpdate(producto(19000));

    final fila = await db.select(db.productosCache).getSingle();
    expect(fila.precioReferencia, 19000);
  });

  test('los datos siguen ahí después de cerrar y reabrir', () async {
    final directorio = await Directory.systemTemp.createTemp('pedidos-test-');
    final archivo = File('${directorio.path}/prueba.sqlite');
    try {
      final primera = AppDatabase.forTesting(NativeDatabase(archivo));
      await primera.into(primera.pedidos).insert(pedido('uuid-1'));
      await primera.into(primera.lineasPedido).insert(linea('uuid-1', 'p001'));
      await primera.close();

      final reabierta = AppDatabase.forTesting(NativeDatabase(archivo));
      final fila = await reabierta.select(reabierta.pedidos).getSingle();
      final lineas = await reabierta.select(reabierta.lineasPedido).get();
      await reabierta.close();

      expect(fila.id, 'uuid-1');
      expect(lineas.single.nombreProducto, 'Hamburguesa');
    } finally {
      await directorio.delete(recursive: true);
    }
  });
}
