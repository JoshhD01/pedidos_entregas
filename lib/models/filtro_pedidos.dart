import 'estado_pedido.dart';

enum FiltroPedidos {
  todos('todos'),
  activos('activos'),
  terminados('terminados');

  const FiltroPedidos(this.valor);

  final String valor;

  bool incluye(EstadoPedido estado) => switch (this) {
    todos => true,
    activos => !estado.esTerminal,
    terminados => estado.esTerminal,
  };

  /// Null si el valor no existe: es una preferencia de pantalla, no un dato del negocio.
  static FiltroPedidos? fromValor(String? valor) {
    for (final filtro in values) {
      if (filtro.valor == valor) return filtro;
    }
    return null;
  }
}
