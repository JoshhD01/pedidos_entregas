/// Estados del negocio. `valor` es el texto que se guarda en Firestore y Drift.
enum EstadoPedido {
  creado('CREADO'),
  confirmado('CONFIRMADO'),
  preparando('PREPARANDO'),
  listo('LISTO'),
  enCamino('EN_CAMINO'),
  entregado('ENTREGADO'),
  rechazado('RECHAZADO'),
  cancelado('CANCELADO');

  const EstadoPedido(this.valor);

  final String valor;

  /// Un pedido terminal no se reactiva.
  bool get esTerminal =>
      this == entregado || this == rechazado || this == cancelado;

  /// Un estado desconocido es un error: nunca se reemplaza por uno válido.
  static EstadoPedido fromValor(String valor) {
    for (final estado in values) {
      if (estado.valor == valor) return estado;
    }
    throw FormatException('Estado de pedido desconocido: $valor');
  }
}
