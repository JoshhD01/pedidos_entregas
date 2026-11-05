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
