import 'dart:async';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';

import '../core/errores.dart';
import '../core/registro_errores.dart';
import '../local/pedido_local_data_source.dart';
import '../models/estado_pedido.dart';
import '../models/estado_sync.dart';
import '../models/linea_pedido.dart';
import '../models/pedido.dart';
import '../models/perfil.dart';
import '../remote/pedido_remote_data_source.dart';

class ResultadoSync {
  final int sincronizados;
  final int pendientes;
  final int rechazados;

  const ResultadoSync({
    required this.sincronizados,
    required this.pendientes,
    required this.rechazados,
  });
}

/// Operaciones del pedido. La implementa Tomás.
abstract class PedidoRepository {
  /// Guarda primero en Drift con UUID nuevo, `EstadoPedido.creado` y
  /// `EstadoSync.pendiente`, y genera el código de recepción una sola vez.
  /// Después intenta enviarlo sin bloquear a quien llama.
  Future<Pedido> crearPedido({
    required String clienteUid,
    required List<LineaPedido> lineas,
    required String direccion,
  });

  /// Pedidos locales del usuario. Nunca incluye los de otra cuenta.
  Stream<List<Pedido>> observarMisPedidos(String clienteUid);

  /// Envía solo los pedidos pendientes de `clienteUid`.
  /// Crea el documento en una transacción si no existe: un reintento nunca
  /// sobrescribe lo que hizo otro rol. Marca sincronizado solo tras la
  /// confirmación remota y si la fila sigue igual a la versión enviada.
  /// Un rechazo del servidor deja el pedido en `EstadoSync.rechazado`.
  Future<ResultadoSync> sincronizarPendientes(String clienteUid);

  /// Borra de Drift un pedido en `EstadoSync.rechazado`.
  Future<void> descartarRechazado(String pedidoId);

  /// Mientras se escuche, copia a Drift el estado remoto de los pedidos del
  /// cliente. Cada respuesta del servidor (hay red) envía los pendientes.
  Stream<void> seguirMisPedidos(String clienteUid);

  /// Solo en `EstadoPedido.creado`. Un pendiente se envía primero: sin
  /// conexión no se cancela, para que el operador no confirme un pedido que
  /// el cliente ve cancelado. La transacción relee el estado remoto.
  Future<void> cancelarPedido(String pedidoId, String clienteUid);

  /// Pedidos remotos que el operador debe revisar.
  Stream<List<Pedido>> observarBandejaOperador();

  /// En una transacción: lee el stock y precio vigentes de todas las líneas,
  /// recalcula el total, descuenta el stock y pasa a `EstadoPedido.confirmado`.
  /// Lanza `ReglaDeNegocioException` si falta stock.
  Future<void> confirmarPedido(String pedidoId);

  /// Pasa un pedido `EstadoPedido.creado` a `EstadoPedido.rechazado`.
  Future<void> rechazarPedido(String pedidoId);

  /// `EstadoPedido.confirmado` → `EstadoPedido.preparando`, en una transacción.
  Future<void> prepararPedido(String pedidoId);

  /// `EstadoPedido.preparando` → `EstadoPedido.listo`, en una transacción.
  Future<void> marcarListo(String pedidoId);

  /// Asigna o cambia el repartidor de un pedido `EstadoPedido.listo`.
  /// El repartidor debe tener `repartidores/{uid}`.
  Future<void> asignarRepartidor(String pedidoId, String repartidorUid);

  /// Perfiles con `Rol.repartidor`.
  Future<List<Perfil>> listarRepartidores();
}

class PedidoRepositoryImpl implements PedidoRepository {
  static const maxProductos = 5;
  static const maxCantidad = 10;

  /// Rechazos definitivos del servidor: el pedido no se reenvía.
  static const codigosDeRechazo = {
    'permission-denied',
    'invalid-argument',
    'failed-precondition',
  };

  final PedidoLocalDataSource local;
  final PedidoRemoteDataSource remote;
  final Duration tiempoLimite;
  final Uuid _uuid = const Uuid();
  final Random _random = Random.secure();
  final _enCurso = <String, Future<ResultadoSync>>{};

  PedidoRepositoryImpl({
    required this.local,
    required this.remote,
    this.tiempoLimite = const Duration(seconds: 10),
  });

  @override
  Future<Pedido> crearPedido({
    required String clienteUid,
    required List<LineaPedido> lineas,
    required String direccion,
  }) async {
    validarPedido(lineas, direccion);
    final ahora = DateTime.now();
    final pedido = Pedido(
      id: _uuid.v4(),
      clienteUid: clienteUid,
      lineas: lineas,
      direccion: direccion.trim(),
      estado: EstadoPedido.creado,
      createdAt: ahora,
      updatedAt: ahora,
      estadoSync: EstadoSync.pendiente,
      codigoRecepcion: _generarCodigo(),
    );
    await local.insertar(pedido);
    _enviarEnSegundoPlano(clienteUid);
    return pedido;
  }

  /// Si falla, el pedido sigue pendiente; solo los errores inesperados se registran.
  void _enviarEnSegundoPlano(String clienteUid) {
    unawaited(
      sincronizarPendientes(clienteUid).then((_) {}, onError: registrarError),
    );
  }

  @override
  Stream<List<Pedido>> observarMisPedidos(String clienteUid) =>
      local.observarDe(clienteUid);

  @override
  Stream<void> seguirMisPedidos(String clienteUid) {
    return remote.observarDeCliente(clienteUid).asyncMap((respuesta) async {
      await local.aplicarRemotos(clienteUid, respuesta.pedidos);
      // shortcut: reintenta solo con la app abierta y sesión de cliente; usar WorkManager si se pide envío en segundo plano real.
      if (respuesta.desdeServidor) _enviarEnSegundoPlano(clienteUid);
    });
  }

  @override
  Future<void> cancelarPedido(String pedidoId, String clienteUid) async {
    var pedido = await local.buscar(pedidoId, clienteUid);
    if (pedido == null ||
        pedido.estado != EstadoPedido.creado ||
        pedido.estadoSync == EstadoSync.rechazado) {
      throw const ReglaDeNegocioException(
        'Solo se puede cancelar un pedido creado.',
      );
    }
    if (pedido.pendingSync) {
      await sincronizarPendientes(clienteUid);
      pedido = await local.buscar(pedidoId, clienteUid);
      if (pedido?.estadoSync != EstadoSync.sincronizado) {
        throw const ReglaDeNegocioException(
          'Sin conexión: el pedido aún no llega al servidor. Intenta de nuevo.',
        );
      }
    }
    await remote.cancelar(pedidoId, clienteUid).timeout(tiempoLimite);
    await local.cambiarEstado(pedidoId, clienteUid, EstadoPedido.cancelado);
  }

  /// Un envío en curso se comparte: dos llamadas simultáneas no cuentan doble.
  @override
  Future<ResultadoSync> sincronizarPendientes(
    String clienteUid,
  ) => _enCurso[clienteUid] ??= _sincronizar(clienteUid).whenComplete(() {
    // Sin llaves devolvería este mismo Future y whenComplete se esperaría a sí mismo.
    _enCurso.remove(clienteUid);
  });

  Future<ResultadoSync> _sincronizar(String clienteUid) async {
    var sincronizados = 0;
    var pendientes = 0;
    var rechazados = 0;

    for (final pedido in await local.pendientesDe(clienteUid)) {
      try {
        await remote.crearSiNoExiste(pedido).timeout(tiempoLimite);
        if (await local.marcarSincronizado(pedido.id, pedido.updatedAt)) {
          sincronizados++;
        } else {
          pendientes++;
        }
      } on FirebaseException catch (error) {
        final rechazado = codigosDeRechazo.contains(error.code);
        await local.marcarError(
          pedido.id,
          rechazado
              ? 'El servidor rechazó el pedido.'
              : 'No se pudo enviar. Se reintentará.',
          rechazado: rechazado,
        );
        rechazado ? rechazados++ : pendientes++;
      } on TimeoutException {
        await local.marcarError(
          pedido.id,
          'Sin conexión. Se reintentará.',
          rechazado: false,
        );
        pendientes++;
      }
    }

    return ResultadoSync(
      sincronizados: sincronizados,
      pendientes: pendientes,
      rechazados: rechazados,
    );
  }

  @override
  Future<void> descartarRechazado(String pedidoId) =>
      local.borrarRechazado(pedidoId);

  @override
  Stream<List<Pedido>> observarBandejaOperador() => remote.observarBandeja();

  @override
  Future<void> confirmarPedido(String pedidoId) =>
      remote.confirmar(pedidoId).timeout(tiempoLimite);

  @override
  Future<void> rechazarPedido(String pedidoId) =>
      remote.rechazar(pedidoId).timeout(tiempoLimite);

  @override
  Future<void> prepararPedido(String pedidoId) =>
      remote.avanzar(pedidoId, EstadoPedido.preparando).timeout(tiempoLimite);

  @override
  Future<void> marcarListo(String pedidoId) =>
      remote.avanzar(pedidoId, EstadoPedido.listo).timeout(tiempoLimite);

  @override
  Future<void> asignarRepartidor(String pedidoId, String repartidorUid) =>
      remote.asignarRepartidor(pedidoId, repartidorUid).timeout(tiempoLimite);

  @override
  Future<List<Perfil>> listarRepartidores() =>
      remote.listarRepartidores().timeout(tiempoLimite);

  String _generarCodigo() =>
      _random.nextInt(1000000).toString().padLeft(6, '0');
}

/// Reglas: 1 a 5 productos diferentes, cantidades de 1 a 10 y dirección.
void validarPedido(List<LineaPedido> lineas, String direccion) {
  if (lineas.isEmpty) {
    throw const ReglaDeNegocioException('Agrega al menos un producto.');
  }
  if (lineas.length > PedidoRepositoryImpl.maxProductos) {
    throw const ReglaDeNegocioException(
      'Un pedido admite máximo ${PedidoRepositoryImpl.maxProductos} productos diferentes.',
    );
  }
  final ids = lineas.map((linea) => linea.productoId).toSet();
  if (ids.length != lineas.length) {
    throw const ReglaDeNegocioException(
      'Hay productos repetidos en el pedido.',
    );
  }
  for (final linea in lineas) {
    if (linea.cantidad < 1 ||
        linea.cantidad > PedidoRepositoryImpl.maxCantidad) {
      throw ReglaDeNegocioException(
        'La cantidad de ${linea.nombreProducto} debe estar entre 1 y '
        '${PedidoRepositoryImpl.maxCantidad}.',
      );
    }
  }
  if (direccion.trim().isEmpty) {
    throw const ReglaDeNegocioException('Indica la dirección de entrega.');
  }
}
