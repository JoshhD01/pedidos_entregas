import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/errores.dart';
import '../models/confirmacion.dart';
import '../models/estado_pedido.dart';
import '../models/pedido.dart';
import '../models/producto.dart';

class PedidoRemoteDataSource {
  final FirebaseFirestore firestore;

  PedidoRemoteDataSource(this.firestore);

  /// Crea el pedido y su código solo si no existe; un reintento no sobrescribe.
  Future<bool> crearSiNoExiste(Pedido pedido) {
    final referencia = firestore.collection('pedidos').doc(pedido.id);
    return firestore.runTransaction((transaccion) async {
      final actual = await transaccion.get(referencia);
      if (actual.exists) return false;
      transaccion.set(referencia, pedido.toFirestore());
      transaccion.set(referencia.collection('privado').doc('codigo'), {
        'codigo': pedido.codigoRecepcion,
      });
      return true;
    });
  }

  Stream<List<Pedido>> observarCreados() {
    return firestore
        .collection('pedidos')
        .where('estado', isEqualTo: EstadoPedido.creado.valor)
        .snapshots()
        .map((consulta) {
          final pedidos = consulta.docs
              .map((doc) => Pedido.fromFirestore(doc.id, doc.data()))
              .toList();
          pedidos.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return pedidos;
        });
  }

  /// En una transacción: lee productos, recalcula, descuenta stock y confirma.
  Future<void> confirmar(String pedidoId) {
    final referencia = firestore.collection('pedidos').doc(pedidoId);
    return firestore.runTransaction((transaccion) async {
      final pedido = await _leerCreado(transaccion, referencia);

      final productos = <String, ProductoOperativo?>{};
      for (final linea in pedido.lineas) {
        final doc = await transaccion.get(_producto(linea.productoId));
        final data = doc.data();
        productos[linea.productoId] = data == null
            ? null
            : ProductoOperativo.fromFirestore(doc.id, data);
      }

      final confirmacion = calcularConfirmacion(pedido.lineas, productos);
      confirmacion.stockRestante.forEach((id, stock) {
        transaccion.update(_producto(id), {'stock': stock});
      });
      transaccion.update(referencia, {
        'lineas': confirmacion.lineas.map((linea) => linea.toMap()).toList(),
        'total': confirmacion.total,
        'estado': EstadoPedido.confirmado.valor,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  Future<void> rechazar(String pedidoId) {
    final referencia = firestore.collection('pedidos').doc(pedidoId);
    return firestore.runTransaction((transaccion) async {
      await _leerCreado(transaccion, referencia);
      transaccion.update(referencia, {
        'estado': EstadoPedido.rechazado.valor,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  /// Solo un pedido en CREADO se puede confirmar o rechazar.
  Future<Pedido> _leerCreado(
    Transaction transaccion,
    DocumentReference<Map<String, dynamic>> referencia,
  ) async {
    final doc = await transaccion.get(referencia);
    final data = doc.data();
    if (data == null) {
      throw const ReglaDeNegocioException('El pedido no existe.');
    }
    final pedido = Pedido.fromFirestore(doc.id, data);
    if (pedido.estado != EstadoPedido.creado) {
      throw const ReglaDeNegocioException('El pedido ya fue procesado.');
    }
    return pedido;
  }

  DocumentReference<Map<String, dynamic>> _producto(String id) =>
      firestore.collection('productos').doc(id);
}
