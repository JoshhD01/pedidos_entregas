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
      await _insertarLineas(pedido);
    });
  }

  Future<void> _insertarLineas(Pedido pedido) {
    return db.batch((batch) {
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
  }

  Future<Pedido?> buscar(String id, String ownerUid) async {
    final consulta = db.select(db.pedidos)
      ..where((p) => p.id.equals(id) & p.ownerUid.equals(ownerUid));
    final pedidos = await _conLineas(await consulta.get());
    return pedidos.isEmpty ? null : pedidos.single;
  }

  /// Copia el estado remoto. Un pendiente solo se toca si el servidor ya lo
  /// procesó: eso prueba que llegó. Nunca toca rechazados ni otras cuentas.
  // shortcut: no importa pedidos que no estén en este dispositivo; agregarlo si se pide historial al reinstalar.
  Future<void> aplicarRemotos(String ownerUid, List<Pedido> remotos) {
    return db.transaction(() async {
      for (final remoto in remotos) {
        if (remoto.clienteUid != ownerUid) continue;
        final aplicables = [
          EstadoSync.sincronizado.valor,
          if (remoto.estado != EstadoPedido.creado) EstadoSync.pendiente.valor,
        ];
        final filas =
            await (db.update(db.pedidos)..where(
                  (p) =>
                      p.id.equals(remoto.id) &
                      p.ownerUid.equals(ownerUid) &
                      p.estadoSync.isIn(aplicables),
                ))
                .write(
                  PedidosCompanion(
                    estado: Value(remoto.estado.valor),
                    repartidorUid: Value(remoto.repartidorUid),
                    updatedAt: Value(remoto.updatedAt),
                    estadoSync: Value(EstadoSync.sincronizado.valor),
                    lastError: const Value(null),
                  ),
                );
        if (filas == 0) continue;
        // Las líneas remotas traen el precio vigente que fijó la confirmación.
        await (db.delete(
          db.lineasPedido,
        )..where((l) => l.pedidoId.equals(remoto.id))).go();
        await _insertarLineas(remoto);
      }
    });
  }

  Future<void> cambiarEstado(String id, String ownerUid, EstadoPedido estado) {
    return (db.update(db.pedidos)
          ..where((p) => p.id.equals(id) & p.ownerUid.equals(ownerUid)))
        .write(PedidosCompanion(estado: Value(estado.valor)));
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
