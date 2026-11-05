import '../models/producto.dart';
import 'app_database.dart';

/// Última copia del catálogo, para consultarlo sin conexión.
class ProductoLocalDataSource {
  final AppDatabase db;

  ProductoLocalDataSource(this.db);

  Future<List<Producto>> obtenerTodos() async {
    final filas = await db.select(db.productosCache).get();
    return filas
        .map(
          (fila) => Producto(
            id: fila.id,
            nombre: fila.nombre,
            categoria: fila.categoria,
            descripcion: fila.descripcion,
            precioReferencia: fila.precioReferencia,
          ),
        )
        .toList();
  }

  /// Reemplaza la copia completa: un producto retirado del catálogo no queda.
  Future<void> reemplazarTodos(List<Producto> productos) {
    return db.transaction(() async {
      await db.delete(db.productosCache).go();
      await db.batch((batch) {
        batch.insertAll(
          db.productosCache,
          productos.map(
            (producto) => ProductosCacheCompanion.insert(
              id: producto.id,
              nombre: producto.nombre,
              categoria: producto.categoria,
              descripcion: producto.descripcion,
              precioReferencia: producto.precioReferencia,
            ),
          ),
        );
      });
    });
  }
}
