import 'package:drift/drift.dart';

import '../models/estado_pedido.dart';
import '../models/estado_sync.dart';
import '../models/linea_pedido.dart';
import '../models/pedido.dart';
import 'app_database.dart';

class PedidoLocalDataSource {
  final AppDatabase db;

  PedidoLocalDataSource(this.db);

  /// Pedido y líneas en una sola transacción.
  Future<void> insertar(Pedido pedido) {
    return db.transaction(() async {
      await db
          .into(db.pedidos)
          .insert(
            PedidosCompanion.insert(
              id: pedido.id,
              ownerUid: pedido.clienteUid,
              direccion: pedido.direccion,
              estado: pedido.estado.valor,
              repartidorUid: Value(pedido.repartidorUid),
              codigoRecepcion: Value(pedido.codigoRecepcion),
              createdAt: pedido.createdAt,
              updatedAt: pedido.updatedAt,
              estadoSync: Value(pedido.estadoSync.valor),
              lastError: Value(pedido.lastError),
            ),
          );
      await db.batch((batch) {
        batch.insertAll(
          db.lineasPedido,
          pedido.lineas.map(
            (linea) => LineasPedidoCompanion.insert(
              pedidoId: pedido.id,
              productoId: linea.productoId,
              nombreProducto: linea.nombreProducto,
              cantidad: linea.cantidad,
              precioUnitario: linea.precioUnitario,
            ),
          ),
        );
      });
    });
  }

  Stream<List<Pedido>> observarDe(String ownerUid) {
    final consulta = db.select(db.pedidos)
      ..where((p) => p.ownerUid.equals(ownerUid))
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]);
    return consulta.watch().asyncMap(_conLineas);
  }

  Future<List<Pedido>> pendientesDe(String ownerUid) async {
    final consulta = db.select(db.pedidos)
      ..where(
        (p) =>
            p.ownerUid.equals(ownerUid) &
            p.estadoSync.equals(EstadoSync.pendiente.valor),
      );
    return _conLineas(await consulta.get());
  }

  /// Solo marca si la fila no cambió desde que se envió.
  Future<bool> marcarSincronizado(String id, DateTime updatedAtEnviado) async {
    final filas =
        await (db.update(db.pedidos)..where(
              (p) =>
                  p.id.equals(id) &
                  p.updatedAt.equals(updatedAtEnviado) &
                  p.estadoSync.equals(EstadoSync.pendiente.valor),
            ))
            .write(
              PedidosCompanion(
                estadoSync: Value(EstadoSync.sincronizado.valor),
                lastError: const Value(null),
              ),
            );
    return filas > 0;
  }

  Future<void> marcarError(
    String id,
    String mensaje, {
    required bool rechazado,
  }) {
    return (db.update(db.pedidos)..where((p) => p.id.equals(id))).write(
      PedidosCompanion(
        estadoSync: Value(
          (rechazado ? EstadoSync.rechazado : EstadoSync.pendiente).valor,
        ),
        lastError: Value(mensaje),
      ),
    );
  }

  Future<void> borrarRechazado(String id) {
    return (db.delete(db.pedidos)..where(
          (p) =>
              p.id.equals(id) & p.estadoSync.equals(EstadoSync.rechazado.valor),
        ))
        .go();
  }

  Future<List<Pedido>> _conLineas(List<PedidoRow> filas) async {
    if (filas.isEmpty) return const [];
    final ids = filas.map((fila) => fila.id).toList();
    final lineas = await (db.select(
      db.lineasPedido,
    )..where((l) => l.pedidoId.isIn(ids))).get();

    return filas.map((fila) {
      return Pedido(
        id: fila.id,
        clienteUid: fila.ownerUid,
        lineas: lineas
            .where((linea) => linea.pedidoId == fila.id)
            .map(
              (linea) => LineaPedido(
                productoId: linea.productoId,
                nombreProducto: linea.nombreProducto,
                cantidad: linea.cantidad,
                precioUnitario: linea.precioUnitario,
              ),
            )
            .toList(),
        direccion: fila.direccion,
        estado: EstadoPedido.fromValor(fila.estado),
        repartidorUid: fila.repartidorUid,
        createdAt: fila.createdAt,
        updatedAt: fila.updatedAt,
        estadoSync: EstadoSync.fromValor(fila.estadoSync),
        lastError: fila.lastError,
        codigoRecepcion: fila.codigoRecepcion,
      );
    }).toList();
  }
}
