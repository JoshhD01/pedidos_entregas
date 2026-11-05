/// Una regla del negocio impidió la operación, por ejemplo falta de stock.
/// `mensaje` se muestra al usuario tal cual.
class ReglaDeNegocioException implements Exception {
  final String mensaje;

  const ReglaDeNegocioException(this.mensaje);

  @override
  String toString() => mensaje;
}
