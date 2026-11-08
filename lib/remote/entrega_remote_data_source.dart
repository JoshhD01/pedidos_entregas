import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/errores.dart';
import '../models/entrega.dart';
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

  /// Ocupa `repartidores/{uid}` en la misma transacción: nunca dos pedidos en camino.
  Future<void> iniciarRecorrido(String pedidoId, String repartidorUid) {
    final pedidoRef = firestore.collection('pedidos').doc(pedidoId);
    final repartidorRef = firestore
        .collection('repartidores')
        .doc(repartidorUid);
    return firestore.runTransaction((transaccion) async {
      final pedidoDoc = await transaccion.get(pedidoRef);
      final repartidorDoc = await transaccion.get(repartidorRef);
      final pedidoData = pedidoDoc.data();
      final repartidorData = repartidorDoc.data();
      if (pedidoData == null) {
        throw const ReglaDeNegocioException('El pedido no existe.');
      }
      if (repartidorData == null) {
        throw const ReglaDeNegocioException(
          'Tu cuenta no está habilitada para repartir.',
        );
      }

      validarInicioRecorrido(
        Pedido.fromFirestore(pedidoDoc.id, pedidoData),
        repartidorUid,
        repartidorData['pedidoEnCamino'] as String?,
      );

      transaccion.update(pedidoRef, {
        'estado': EstadoPedido.enCamino.valor,
        'updatedAt': Timestamp.now(),
      });
      transaccion.update(repartidorRef, {'pedidoEnCamino': pedidoId});
    });
  }

  /// La regla de Firestore compara `entrega/codigo` con `privado/codigo`;
  /// el repartidor nunca lee el código del cliente.
  Future<void> entregar(String pedidoId, String repartidorUid, String codigo) {
    final pedidoRef = firestore.collection('pedidos').doc(pedidoId);
    final repartidorRef = firestore
        .collection('repartidores')
        .doc(repartidorUid);
    return firestore.runTransaction((transaccion) async {
      final pedidoDoc = await transaccion.get(pedidoRef);
      final pedidoData = pedidoDoc.data();
      if (pedidoData == null) {
        throw const ReglaDeNegocioException('El pedido no existe.');
      }
      validarEntrega(
        Pedido.fromFirestore(pedidoDoc.id, pedidoData),
        repartidorUid,
      );

      transaccion.set(pedidoRef.collection('entrega').doc('codigo'), {
        'codigo': codigo,
      });
      transaccion.update(pedidoRef, {
        'estado': EstadoPedido.entregado.valor,
        'updatedAt': Timestamp.now(),
      });
      transaccion.update(repartidorRef, {'pedidoEnCamino': null});
    });
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
