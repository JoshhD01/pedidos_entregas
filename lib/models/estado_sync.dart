/// Estado de sincronización, independiente del estado del negocio.
enum EstadoSync {
  /// Guardado localmente; se puede reintentar el envío.
  pendiente('PENDIENTE'),

  /// Confirmado por Firestore.
  sincronizado('SINCRONIZADO'),

  /// El servidor lo rechazó: no se reenvía. El usuario corrige o descarta.
  rechazado('RECHAZADO');

  const EstadoSync(this.valor);

  final String valor;

  static EstadoSync fromValor(String valor) {
    for (final estado in values) {
      if (estado.valor == valor) return estado;
    }
    throw FormatException('Estado de sincronización desconocido: $valor');
  }
}
