/// Convierte 18000 en "$ 18.000 COP".
String formatearPrecio(int precio) {
  final digitos = precio.toString();
  final conPuntos = digitos.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+$)'),
    (_) => '.',
  );
  return '\$ $conPuntos COP';
}

String formatearFecha(DateTime fecha) {
  String dos(int valor) => valor.toString().padLeft(2, '0');
  return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year} '
      '${dos(fecha.hour)}:${dos(fecha.minute)}';
}
