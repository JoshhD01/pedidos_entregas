/// Convierte 18000 en "$ 18.000 COP".
String formatearPrecio(int precio) {
  final digitos = precio.toString();
  final conPuntos = digitos.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+$)'),
    (_) => '.',
  );
  return '\$ $conPuntos COP';
}
