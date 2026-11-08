import 'package:firebase_core/firebase_core.dart';

import '../core/errores.dart';
import '../models/entrega.dart';
import '../models/pedido.dart';
import '../remote/entrega_remote_data_source.dart';

/// Operaciones del repartidor.
abstract class EntregaRepository {
  /// Pedidos LISTO y EN_CAMINO asignados a `repartidorUid`.
  Stream<List<Pedido>> observarAsignados(String repartidorUid);

  /// LISTO → EN_CAMINO. Lanza `ReglaDeNegocioException` si ya tiene uno en camino.
  Future<void> iniciarRecorrido(String pedidoId, String repartidorUid);

  /// EN_CAMINO → ENTREGADO. Código incorrecto: `ReglaDeNegocioException`.
  Future<void> entregar(String pedidoId, String repartidorUid, String codigo);
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

  @override
  Future<void> entregar(
    String pedidoId,
    String repartidorUid,
    String codigo,
  ) async {
    validarCodigo(codigo);
    try {
      await remote
          .entregar(pedidoId, repartidorUid, codigo)
          .timeout(tiempoLimite);
    } on FirebaseException catch (error) {
      // Las reglas rechazan la escritura cuando el código no coincide.
      if (error.code == 'permission-denied') {
        throw const ReglaDeNegocioException('Código incorrecto.');
      }
      rethrow;
    }
  }
}
