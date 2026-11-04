class LineaPedido {
  final String productoId;

  /// Copiado al crear el pedido: no depende del catálogo.
  final String nombreProducto;
  final int cantidad;
  final int precioUnitario;

  const LineaPedido({
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
  });

  int get subtotal => cantidad * precioUnitario;

  factory LineaPedido.fromMap(Map<String, dynamic> map) {
    try {
      return LineaPedido(
        productoId: map['productoId'] as String,
        nombreProducto: map['nombreProducto'] as String,
        cantidad: (map['cantidad'] as num).toInt(),
        precioUnitario: (map['precioUnitario'] as num).toInt(),
      );
    } on TypeError {
      throw const FormatException('Línea de pedido con formato inválido');
    }
  }

  Map<String, dynamic> toMap() => {
    'productoId': productoId,
    'nombreProducto': nombreProducto,
    'cantidad': cantidad,
    'precioUnitario': precioUnitario,
  };
}
