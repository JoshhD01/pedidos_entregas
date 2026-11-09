import '../core/errores.dart';
import 'estado_pedido.dart';
import 'pedido.dart';

/// Únicos cambios de estado permitidos. Los terminales no tienen salida.
const siguientes = <EstadoPedido, Set<EstadoPedido>>{
  EstadoPedido.creado: {
    EstadoPedido.confirmado,
    EstadoPedido.rechazado,
    EstadoPedido.cancelado,
  },
  EstadoPedido.confirmado: {EstadoPedido.preparando},
  EstadoPedido.preparando: {EstadoPedido.listo},
  EstadoPedido.listo: {EstadoPedido.enCamino},
  EstadoPedido.enCamino: {EstadoPedido.entregado},
};

void validarTransicion(Pedido pedido, EstadoPedido hacia) {
  if (!(siguientes[pedido.estado]?.contains(hacia) ?? false)) {
    throw const ReglaDeNegocioException('El pedido ya cambió de estado.');
  }
}

/// Se asigna o reasigna solo en LISTO: al iniciar el recorrido ya no se cambia.
void validarAsignacion(Pedido pedido) {
  if (pedido.estado != EstadoPedido.listo) {
    throw const ReglaDeNegocioException(
      'Solo se asigna repartidor a un pedido listo.',
    );
  }
}
