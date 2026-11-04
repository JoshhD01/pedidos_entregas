/// Producto del catálogo HTTP. Su precio es solo de referencia.
class Producto {
  final String id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final int precioReferencia;

  const Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.precioReferencia,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    try {
      final precio = (json['precio'] as num).toInt();
      if (precio < 0) {
        throw const FormatException('Producto con precio negativo');
      }
      return Producto(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        categoria: json['categoria'] as String,
        descripcion: json['descripcion'] as String,
        precioReferencia: precio,
      );
    } on TypeError {
      throw const FormatException('Producto con formato inválido');
    }
  }
}

/// Documento `productos/{id}`: valores vigentes que autorizan una operación.
/// Su id es el mismo del catálogo HTTP.
class ProductoOperativo {
  final String id;
  final String nombre;
  final int precio;
  final int stock;

  const ProductoOperativo({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
  });

  factory ProductoOperativo.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    try {
      return ProductoOperativo(
        id: id,
        nombre: data['nombre'] as String,
        precio: (data['precio'] as num).toInt(),
        stock: (data['stock'] as num).toInt(),
      );
    } on TypeError {
      throw const FormatException('Producto operativo con formato inválido');
    }
  }

  Map<String, dynamic> toFirestore() => {
    'nombre': nombre,
    'precio': precio,
    'stock': stock,
  };
}
