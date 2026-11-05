import '../core/errores.dart';
import '../local/producto_local_data_source.dart';
import '../models/producto.dart';
import '../remote/producto_remote_data_source.dart';
import '../services/producto_service.dart';

class ResultadoCatalogo {
  final List<Producto> productos;

  /// Si no es null, la petición falló y `productos` es la última copia guardada.
  final String? avisoCopiaLocal;

  const ResultadoCatalogo(this.productos, {this.avisoCopiaLocal});
}

/// Catálogo de referencia (HTTP y copia en Drift) y valores vigentes (Firestore).
abstract class ProductoRepository {
  /// Pide el catálogo por HTTP y actualiza la copia local. Si falla, devuelve
  /// la copia local con un aviso. Sin copia, lanza `ApiException`.
  Future<ResultadoCatalogo> obtenerCatalogo();

  /// Precio y stock vigentes en Firestore. Null si el producto no existe.
  Future<ProductoOperativo?> obtenerOperativo(String productoId);
}

class ProductoRepositoryImpl implements ProductoRepository {
  final ProductoService service;
  final ProductoLocalDataSource local;
  final ProductoRemoteDataSource remote;

  /// Firestore puede esperar indefinidamente sin conexión.
  final Duration tiempoLimite;

  ProductoRepositoryImpl({
    required this.service,
    required this.local,
    required this.remote,
    this.tiempoLimite = const Duration(seconds: 10),
  });

  @override
  Future<ResultadoCatalogo> obtenerCatalogo() async {
    try {
      final productos = await service.obtenerProductos();
      await local.reemplazarTodos(productos);
      return ResultadoCatalogo(productos);
    } on ApiException catch (error) {
      final copia = await local.obtenerTodos();
      if (copia.isEmpty) rethrow;
      return ResultadoCatalogo(copia, avisoCopiaLocal: error.mensaje);
    }
  }

  @override
  Future<ProductoOperativo?> obtenerOperativo(String productoId) async {
    final datos = await remote.obtener(productoId).timeout(tiempoLimite);
    if (datos == null) return null;
    return ProductoOperativo.fromFirestore(productoId, datos);
  }
}
