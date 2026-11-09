import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/errores.dart';
import '../core/registro_errores.dart';
import '../models/confirmacion.dart';
import '../models/estado_pedido.dart';
import '../models/pedido.dart';
import '../models/perfil.dart';
import '../models/producto.dart';
import '../models/transiciones.dart';
import 'entrega_remote_data_source.dart';

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

  /// Pedidos del cliente. `desdeServidor` indica que hay conexión.
  Stream<({List<Pedido> pedidos, bool desdeServidor})> observarDeCliente(
    String clienteUid,
  ) {
    return firestore
        .collection('pedidos')
        .where('clienteUid', isEqualTo: clienteUid)
        .snapshots(includeMetadataChanges: true)
        .map(
          (consulta) => (
            pedidos: pedidosValidos({
              for (final doc in consulta.docs) doc.id: doc.data(),
            }),
            desdeServidor: !consulta.metadata.isFromCache,
          ),
        );
  }

  /// Solo el dueño y solo en CREADO: si el operador ya lo tomó, gana el operador.
  Future<void> cancelar(String pedidoId, String clienteUid) {
    final referencia = firestore.collection('pedidos').doc(pedidoId);
    return firestore.runTransaction((transaccion) async {
      final pedido = await _leer(transaccion, referencia);
      if (pedido.clienteUid != clienteUid) {
        throw const ReglaDeNegocioException('Este pedido no es tuyo.');
      }
      validarTransicion(pedido, EstadoPedido.cancelado);
      transaccion.update(referencia, {
        'estado': EstadoPedido.cancelado.valor,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  /// Pedidos que todavía dependen del operador.
  Stream<List<Pedido>> observarBandeja() {
    return firestore
        .collection('pedidos')
        .where(
          'estado',
          whereIn: [
            EstadoPedido.creado.valor,
            EstadoPedido.confirmado.valor,
            EstadoPedido.preparando.valor,
            EstadoPedido.listo.valor,
          ],
        )
        .snapshots()
        .map(
          (consulta) => pedidosValidos({
            for (final doc in consulta.docs) doc.id: doc.data(),
          }),
        );
  }

  /// Relee el estado en la transacción: si otro rol lo cambió, se rechaza.
  Future<void> avanzar(String pedidoId, EstadoPedido hacia) {
    final referencia = firestore.collection('pedidos').doc(pedidoId);
    return firestore.runTransaction((transaccion) async {
      validarTransicion(await _leer(transaccion, referencia), hacia);
      transaccion.update(referencia, {
        'estado': hacia.valor,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  /// Solo se asigna a quien tiene `repartidores/{uid}`: sin él no puede iniciar el recorrido.
  Future<void> asignarRepartidor(String pedidoId, String repartidorUid) {
    final referencia = firestore.collection('pedidos').doc(pedidoId);
    final repartidor = firestore.collection('repartidores').doc(repartidorUid);
    return firestore.runTransaction((transaccion) async {
      final pedido = await _leer(transaccion, referencia);
      if (!(await transaccion.get(repartidor)).exists) {
        throw const ReglaDeNegocioException(
          'Ese repartidor no está habilitado.',
        );
      }
      validarAsignacion(pedido);
      transaccion.update(referencia, {
        'repartidorUid': repartidorUid,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  Future<List<Perfil>> listarRepartidores() async {
    final consulta = await firestore
        .collection('perfiles')
        .where('rol', isEqualTo: Rol.repartidor.valor)
        .get();
    final repartidores = <Perfil>[];
    for (final doc in consulta.docs) {
      try {
        repartidores.add(Perfil.fromFirestore(doc.id, doc.data()));
      } on FormatException catch (error, stack) {
        registrarError(error, stack);
      }
    }
    repartidores.sort((a, b) => a.nombre.compareTo(b.nombre));
    return repartidores;
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

  Future<Pedido> _leer(
    Transaction transaccion,
    DocumentReference<Map<String, dynamic>> referencia,
  ) async {
    final doc = await transaccion.get(referencia);
    final data = doc.data();
    if (data == null) {
      throw const ReglaDeNegocioException('El pedido no existe.');
    }
    return Pedido.fromFirestore(doc.id, data);
  }

  /// Solo un pedido en CREADO se puede confirmar o rechazar.
  Future<Pedido> _leerCreado(
    Transaction transaccion,
    DocumentReference<Map<String, dynamic>> referencia,
  ) async {
    final pedido = await _leer(transaccion, referencia);
    if (pedido.estado != EstadoPedido.creado) {
      throw const ReglaDeNegocioException('El pedido ya fue procesado.');
    }
    return pedido;
  }

  DocumentReference<Map<String, dynamic>> _producto(String id) =>
      firestore.collection('productos').doc(id);
}
