import '../models/producto.dart';

/// Catálogo de referencia (HTTP y copia en Drift) y valores vigentes (Firestore).
abstract class ProductoRepository {
  /// Pide el catálogo por HTTP y actualiza la copia local.
  /// Sin conexión devuelve la copia local si existe.
  Future<List<Producto>> obtenerCatalogo();

  /// Precio y stock vigentes en Firestore. Null si el producto no existe.
  Future<ProductoOperativo?> obtenerOperativo(String productoId);
}
