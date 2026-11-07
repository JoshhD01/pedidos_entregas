import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pedido.dart';

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
}
