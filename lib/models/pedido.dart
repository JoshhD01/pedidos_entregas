import 'package:cloud_firestore/cloud_firestore.dart';

import 'estado_pedido.dart';
import 'estado_sync.dart';
import 'linea_pedido.dart';

class Pedido {
  /// UUID generado en el cliente antes del primer envío. Se reutiliza al reintentar.
  final String id;
  final String clienteUid;
  final List<LineaPedido> lineas;
  final String direccion;
  final EstadoPedido estado;
  final String? repartidorUid;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Campos locales: no van en el documento del pedido.
  final EstadoSync estadoSync;
  final String? lastError;

  /// Solo se guarda en Drift y en `pedidos/{id}/privado/codigo`.
  final String? codigoRecepcion;

  const Pedido({
    required this.id,
    required this.clienteUid,
    required this.lineas,
    required this.direccion,
    required this.estado,
    this.repartidorUid,
    required this.createdAt,
    required this.updatedAt,
    required this.estadoSync,
    this.lastError,
    this.codigoRecepcion,
  });

  /// El total siempre se calcula: no existe forma de digitarlo.
  int get total => lineas.fold(0, (suma, linea) => suma + linea.subtotal);

  /// Solo los pendientes se pueden reenviar. Un rechazado no se reenvía.
  bool get pendingSync => estadoSync == EstadoSync.pendiente;

  factory Pedido.fromFirestore(String id, Map<String, dynamic> data) {
    try {
      return Pedido(
        id: id,
        clienteUid: data['clienteUid'] as String,
        lineas: (data['lineas'] as List)
            .map(
              (linea) =>
                  LineaPedido.fromMap(Map<String, dynamic>.from(linea as Map)),
            )
            .toList(),
        direccion: data['direccion'] as String,
        estado: EstadoPedido.fromValor(data['estado'] as String),
        repartidorUid: data['repartidorUid'] as String?,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        estadoSync: EstadoSync.sincronizado,
      );
    } on TypeError {
      throw const FormatException('Pedido con formato inválido');
    }
  }

  /// No incluye el código de recepción ni los campos locales.
  Map<String, dynamic> toFirestore() => {
    'clienteUid': clienteUid,
    'lineas': lineas.map((linea) => linea.toMap()).toList(),
    'total': total,
    'direccion': direccion,
    'estado': estado.valor,
    'repartidorUid': repartidorUid,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
