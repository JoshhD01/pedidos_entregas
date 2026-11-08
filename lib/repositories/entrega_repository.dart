import '../models/pedido.dart';
import '../remote/entrega_remote_data_source.dart';

/// Operaciones del repartidor.
abstract class EntregaRepository {
  /// Pedidos LISTO y EN_CAMINO asignados a `repartidorUid`.
  Stream<List<Pedido>> observarAsignados(String repartidorUid);
}

class EntregaRepositoryImpl implements EntregaRepository {
  final EntregaRemoteDataSource remote;

  EntregaRepositoryImpl({required this.remote});

  @override
  Stream<List<Pedido>> observarAsignados(String repartidorUid) =>
      remote.observarAsignados(repartidorUid);
}
