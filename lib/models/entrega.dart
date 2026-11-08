import '../core/errores.dart';
import 'estado_pedido.dart';
import 'pedido.dart';

void validarInicioRecorrido(
  Pedido pedido,
  String repartidorUid,
  String? pedidoEnCamino,
) {
  if (pedido.repartidorUid != repartidorUid) {
    throw const ReglaDeNegocioException('Este pedido no está asignado a ti.');
  }
  if (pedido.estado != EstadoPedido.listo) {
    throw const ReglaDeNegocioException(
      'El pedido ya no está listo para salir.',
    );
  }
  if (pedidoEnCamino != null && pedidoEnCamino != pedido.id) {
    throw const ReglaDeNegocioException(
      'Ya tienes un pedido en camino. Entrégalo antes de iniciar otro.',
    );
  }
}
