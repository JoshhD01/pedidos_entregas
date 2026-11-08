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

void validarEntrega(Pedido pedido, String repartidorUid) {
  if (pedido.repartidorUid != repartidorUid) {
    throw const ReglaDeNegocioException('Este pedido no está asignado a ti.');
  }
  if (pedido.estado != EstadoPedido.enCamino) {
    throw const ReglaDeNegocioException('El pedido no está en camino.');
  }
}

void validarCodigo(String codigo) {
  if (!RegExp(r'^\d{6}$').hasMatch(codigo)) {
    throw const ReglaDeNegocioException('El código tiene 6 dígitos.');
  }
}
