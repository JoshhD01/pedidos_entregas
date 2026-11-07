import 'dart:math';

import 'package:uuid/uuid.dart';

import '../core/errores.dart';
import '../local/pedido_local_data_source.dart';
import '../models/estado_pedido.dart';
import '../models/estado_sync.dart';
import '../models/linea_pedido.dart';
import '../models/pedido.dart';

class ResultadoSync {
  final int sincronizados;
  final int pendientes;
  final int rechazados;

  const ResultadoSync({
    required this.sincronizados,
    required this.pendientes,
    required this.rechazados,
  });
}

/// Operaciones del pedido. La implementa Tomás.
abstract class PedidoRepository {
  /// Guarda primero en Drift con UUID nuevo, `EstadoPedido.creado` y
  /// `EstadoSync.pendiente`, y genera el código de recepción una sola vez.
  /// Después intenta enviarlo sin bloquear a quien llama.
  Future<Pedido> crearPedido({
    required String clienteUid,
    required List<LineaPedido> lineas,
    required String direccion,
  });

  /// Pedidos locales del usuario. Nunca incluye los de otra cuenta.
  Stream<List<Pedido>> observarMisPedidos(String clienteUid);

  /// Envía solo los pedidos pendientes de `clienteUid`.
  /// Crea el documento en una transacción si no existe: un reintento nunca
  /// sobrescribe lo que hizo otro rol. Marca sincronizado solo tras la
  /// confirmación remota y si la fila sigue igual a la versión enviada.
  /// Un rechazo del servidor deja el pedido en `EstadoSync.rechazado`.
  Future<ResultadoSync> sincronizarPendientes(String clienteUid);

  /// Borra de Drift un pedido en `EstadoSync.rechazado`.
  Future<void> descartarRechazado(String pedidoId);

  /// Pedidos remotos que el operador debe revisar.
  Stream<List<Pedido>> observarBandejaOperador();

  /// En una transacción: lee el stock y precio vigentes de todas las líneas,
  /// recalcula el total, descuenta el stock y pasa a `EstadoPedido.confirmado`.
  /// Lanza `ReglaDeNegocioException` si falta stock.
  Future<void> confirmarPedido(String pedidoId);

  /// Pasa un pedido `EstadoPedido.creado` a `EstadoPedido.rechazado`.
  Future<void> rechazarPedido(String pedidoId);
}

class PedidoRepositoryImpl implements PedidoRepository {
  static const maxProductos = 5;
  static const maxCantidad = 10;

  final PedidoLocalDataSource local;
  final Uuid _uuid = const Uuid();
  final Random _random = Random.secure();

  PedidoRepositoryImpl({required this.local});

  @override
  Future<Pedido> crearPedido({
    required String clienteUid,
    required List<LineaPedido> lineas,
    required String direccion,
  }) async {
    validarPedido(lineas, direccion);
    final ahora = DateTime.now();
    final pedido = Pedido(
      id: _uuid.v4(),
      clienteUid: clienteUid,
      lineas: lineas,
      direccion: direccion.trim(),
      estado: EstadoPedido.creado,
      createdAt: ahora,
      updatedAt: ahora,
      estadoSync: EstadoSync.pendiente,
      codigoRecepcion: _generarCodigo(),
    );
    await local.insertar(pedido);
    return pedido;
  }

  @override
  Stream<List<Pedido>> observarMisPedidos(String clienteUid) =>
      local.observarDe(clienteUid);

  @override
  Future<ResultadoSync> sincronizarPendientes(String clienteUid) =>
      throw UnimplementedError();

  @override
  Future<void> descartarRechazado(String pedidoId) =>
      local.borrarRechazado(pedidoId);

  @override
  Stream<List<Pedido>> observarBandejaOperador() => throw UnimplementedError();

  @override
  Future<void> confirmarPedido(String pedidoId) => throw UnimplementedError();

  @override
  Future<void> rechazarPedido(String pedidoId) => throw UnimplementedError();

  String _generarCodigo() =>
      _random.nextInt(1000000).toString().padLeft(6, '0');
}

/// Reglas: 1 a 5 productos diferentes, cantidades de 1 a 10 y dirección.
void validarPedido(List<LineaPedido> lineas, String direccion) {
  if (lineas.isEmpty) {
    throw const ReglaDeNegocioException('Agrega al menos un producto.');
  }
  if (lineas.length > PedidoRepositoryImpl.maxProductos) {
    throw const ReglaDeNegocioException(
      'Un pedido admite máximo ${PedidoRepositoryImpl.maxProductos} productos diferentes.',
    );
  }
  final ids = lineas.map((linea) => linea.productoId).toSet();
  if (ids.length != lineas.length) {
    throw const ReglaDeNegocioException(
      'Hay productos repetidos en el pedido.',
    );
  }
  for (final linea in lineas) {
    if (linea.cantidad < 1 ||
        linea.cantidad > PedidoRepositoryImpl.maxCantidad) {
      throw ReglaDeNegocioException(
        'La cantidad de ${linea.nombreProducto} debe estar entre 1 y '
        '${PedidoRepositoryImpl.maxCantidad}.',
      );
    }
  }
  if (direccion.trim().isEmpty) {
    throw const ReglaDeNegocioException('Indica la dirección de entrega.');
  }
}
