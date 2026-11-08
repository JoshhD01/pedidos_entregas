import '../models/pedido.dart';
import '../remote/entrega_remote_data_source.dart';

/// Operaciones del repartidor.
abstract class EntregaRepository {
  /// Pedidos LISTO y EN_CAMINO asignados a `repartidorUid`.
  Stream<List<Pedido>> observarAsignados(String repartidorUid);

  /// LISTO → EN_CAMINO. Lanza `ReglaDeNegocioException` si ya tiene uno en camino.
  Future<void> iniciarRecorrido(String pedidoId, String repartidorUid);
}

class EntregaRepositoryImpl implements EntregaRepository {
  final EntregaRemoteDataSource remote;
  final Duration tiempoLimite;

  EntregaRepositoryImpl({
    required this.remote,
    this.tiempoLimite = const Duration(seconds: 10),
  });

  @override
  Stream<List<Pedido>> observarAsignados(String repartidorUid) =>
      remote.observarAsignados(repartidorUid);

  @override
  Future<void> iniciarRecorrido(String pedidoId, String repartidorUid) =>
      remote.iniciarRecorrido(pedidoId, repartidorUid).timeout(tiempoLimite);
}
