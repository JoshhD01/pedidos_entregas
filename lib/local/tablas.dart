import 'package:drift/drift.dart';

@DataClassName('PedidoRow')
class Pedidos extends Table {
  /// UUID generado en el cliente: es el mismo id del documento en Firestore.
  TextColumn get id => text()();

  /// Toda consulta local se filtra por este uid para no mezclar cuentas.
  TextColumn get ownerUid => text()();
  TextColumn get direccion => text()();

  /// `EstadoPedido.valor`.
  TextColumn get estado => text()();
  TextColumn get repartidorUid => text().nullable()();

  /// Se genera una vez al crear el pedido. Reintentar no lo cambia.
  TextColumn get codigoRecepcion => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// `EstadoSync.valor`.
  TextColumn get estadoSync =>
      text().withDefault(const Constant('PENDIENTE'))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LineaPedidoRow')
class LineasPedido extends Table {
  @override
  String get tableName => 'lineas_pedido';

  IntColumn get id => integer().autoIncrement()();

  /// Borrar el pedido borra sus líneas.
  TextColumn get pedidoId =>
      text().references(Pedidos, #id, onDelete: KeyAction.cascade)();
  TextColumn get productoId => text()();
  TextColumn get nombreProducto => text()();
  IntColumn get cantidad => integer()();
  IntColumn get precioUnitario => integer()();

  /// Un pedido contiene productos diferentes.
  @override
  List<Set<Column>> get uniqueKeys => [
    {pedidoId, productoId},
  ];
}

/// Última copia del catálogo HTTP, para armar pedidos sin conexión.
/// Solo es referencia: no autoriza stock ni precio vigente.
@DataClassName('ProductoCacheRow')
class ProductosCache extends Table {
  @override
  String get tableName => 'productos_cache';

  TextColumn get id => text()();
  TextColumn get nombre => text()();
  TextColumn get categoria => text()();
  TextColumn get descripcion => text()();
  IntColumn get precioReferencia => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
