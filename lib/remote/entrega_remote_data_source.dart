import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/estado_pedido.dart';
import '../models/pedido.dart';

class EntregaRemoteDataSource {
  final FirebaseFirestore firestore;

  EntregaRemoteDataSource(this.firestore);

  Stream<List<Pedido>> observarAsignados(String repartidorUid) {
    return firestore
        .collection('pedidos')
        .where('repartidorUid', isEqualTo: repartidorUid)
        .where(
          'estado',
          whereIn: [EstadoPedido.listo.valor, EstadoPedido.enCamino.valor],
        )
        .snapshots()
        .map(
          (consulta) => pedidosValidos({
            for (final doc in consulta.docs) doc.id: doc.data(),
          }),
        );
  }
}

/// Omite los documentos con formato inválido para no romper la bandeja.
List<Pedido> pedidosValidos(Map<String, Map<String, dynamic>> documentos) {
  final pedidos = <Pedido>[];
  documentos.forEach((id, data) {
    try {
      pedidos.add(Pedido.fromFirestore(id, data));
    } on FormatException {
      return;
    }
  });
  pedidos.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return pedidos;
}
