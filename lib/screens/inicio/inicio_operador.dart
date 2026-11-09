import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/errores.dart';
import '../../core/formato.dart';
import '../../models/estado_pedido.dart';
import '../../models/pedido.dart';
import '../../models/perfil.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/pedido_repository.dart';
import '../../widgets/boton_cerrar_sesion.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/loading_view.dart';
import '../pedidos/mis_pedidos_screen.dart';

class InicioOperador extends StatefulWidget {
  final Perfil perfil;
  final AuthRepository authRepository;
  final PedidoRepository pedidoRepository;

  const InicioOperador({
    super.key,
    required this.perfil,
    required this.authRepository,
    required this.pedidoRepository,
  });

  @override
  State<InicioOperador> createState() => _InicioOperadorState();
}

class _InicioOperadorState extends State<InicioOperador> {
  late final Stream<List<Pedido>> _bandeja = widget.pedidoRepository
      .observarBandejaOperador();
  final _procesando = <String>{};
  List<Perfil>? _repartidores;

  @override
  void initState() {
    super.initState();
    _cargarRepartidores().catchError((_) => const <Perfil>[]);
  }

  Future<List<Perfil>> _cargarRepartidores() async {
    final repartidores = await widget.pedidoRepository.listarRepartidores();
    if (mounted) setState(() => _repartidores = repartidores);
    return repartidores;
  }

  String? _nombreRepartidor(String uid) {
    for (final repartidor in _repartidores ?? const <Perfil>[]) {
      if (repartidor.uid == uid) return repartidor.nombre;
    }
    return null;
  }

  Future<void> _procesar(
    Pedido pedido,
    Future<void> Function() accion,
    String exito,
  ) async {
    setState(() => _procesando.add(pedido.id));
    String mensaje;
    try {
      await accion();
      mensaje = exito;
    } on ReglaDeNegocioException catch (error) {
      mensaje = error.mensaje;
    } on TimeoutException {
      // La transacción pudo completarse en el servidor; reintentar es seguro.
      mensaje =
          'Sin respuesta del servidor. Revisa la bandeja antes de reintentar.';
    } catch (_) {
      mensaje = 'No se pudo actualizar el pedido.';
    }
    if (!mounted) return;
    setState(() => _procesando.remove(pedido.id));
    _avisar(mensaje);
  }

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _asignar(Pedido pedido) async {
    List<Perfil> repartidores;
    try {
      repartidores = _repartidores ?? await _cargarRepartidores();
    } catch (_) {
      _avisar('No se pudo cargar la lista de repartidores.');
      return;
    }
    if (!mounted) return;
    if (repartidores.isEmpty) {
      _avisar('No hay repartidores registrados.');
      return;
    }
    final elegido = await showDialog<Perfil>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Asignar repartidor'),
        children: [
          for (final repartidor in repartidores)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, repartidor),
              child: Text(
                repartidor.uid == pedido.repartidorUid
                    ? '${repartidor.nombre} (actual)'
                    : repartidor.nombre,
              ),
            ),
        ],
      ),
    );
    if (elegido == null) return;
    await _procesar(
      pedido,
      () => widget.pedidoRepository.asignarRepartidor(pedido.id, elegido.uid),
      'Pedido asignado a ${elegido.nombre}.',
    );
  }

  List<Widget> _acciones(Pedido pedido) {
    final repositorio = widget.pedidoRepository;
    final ocupado = _procesando.contains(pedido.id);

    Widget principal(String texto, VoidCallback accion) => FilledButton(
      onPressed: ocupado ? null : accion,
      child: ocupado
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(texto),
    );

    return switch (pedido.estado) {
      EstadoPedido.creado => [
        OutlinedButton(
          onPressed: ocupado
              ? null
              : () => _procesar(
                  pedido,
                  () => repositorio.rechazarPedido(pedido.id),
                  'Pedido rechazado.',
                ),
          child: const Text('Rechazar'),
        ),
        principal(
          'Confirmar',
          () => _procesar(
            pedido,
            () => repositorio.confirmarPedido(pedido.id),
            'Pedido confirmado.',
          ),
        ),
      ],
      EstadoPedido.confirmado => [
        principal(
          'Empezar preparación',
          () => _procesar(
            pedido,
            () => repositorio.prepararPedido(pedido.id),
            'Pedido en preparación.',
          ),
        ),
      ],
      EstadoPedido.preparando => [
        principal(
          'Marcar listo',
          () => _procesar(
            pedido,
            () => repositorio.marcarListo(pedido.id),
            'Pedido listo.',
          ),
        ),
      ],
      EstadoPedido.listo => [
        principal(
          pedido.repartidorUid == null
              ? 'Asignar repartidor'
              : 'Cambiar repartidor',
          () => _asignar(pedido),
        ),
      ],
      _ => const [],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bandeja del operador'),
        actions: [BotonCerrarSesion(authRepository: widget.authRepository)],
      ),
      body: StreamBuilder<List<Pedido>>(
        stream: _bandeja,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const EmptyView(
              icono: Icons.error_outline,
              mensaje: 'No se pudo cargar la bandeja.',
            );
          }
          final pedidos = snapshot.data;
          if (pedidos == null) return const LoadingView();
          if (pedidos.isEmpty) {
            return EmptyView(
              icono: Icons.inbox_outlined,
              mensaje:
                  'Hola, ${widget.perfil.nombre}. No hay pedidos por revisar.',
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(
              12,
              12,
              12,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            itemCount: pedidos.length,
            itemBuilder: (context, indice) {
              final pedido = pedidos[indice];
              final repartidorUid = pedido.repartidorUid;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              formatearFecha(pedido.createdAt),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(etiquetaEstado(pedido.estado)),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      for (final linea in pedido.lineas)
                        Text('${linea.cantidad} × ${linea.nombreProducto}'),
                      const SizedBox(height: 4),
                      Text(
                        '${pedido.estado == EstadoPedido.creado ? 'Total estimado' : 'Total'}: '
                        '${formatearPrecio(pedido.total)}',
                      ),
                      Text(pedido.direccion),
                      if (repartidorUid != null)
                        Text(
                          'Repartidor: '
                          '${_nombreRepartidor(repartidorUid) ?? 'asignado'}',
                        ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _acciones(pedido),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
