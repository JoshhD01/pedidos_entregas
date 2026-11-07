import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/errores.dart';
import '../../core/formato.dart';
import '../../models/pedido.dart';
import '../../models/perfil.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/pedido_repository.dart';
import '../../widgets/boton_cerrar_sesion.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/loading_view.dart';

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

  Future<void> _procesar(
    Pedido pedido,
    Future<void> Function(String) accion,
    String exito,
  ) async {
    setState(() => _procesando.add(pedido.id));
    String mensaje;
    try {
      await accion(pedido.id);
      mensaje = exito;
    } on ReglaDeNegocioException catch (error) {
      mensaje = error.mensaje;
    } on TimeoutException {
      mensaje = 'Sin conexión. Intenta de nuevo.';
    } catch (_) {
      mensaje = 'No se pudo actualizar el pedido.';
    }
    if (!mounted) return;
    setState(() => _procesando.remove(pedido.id));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
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
              final ocupado = _procesando.contains(pedido.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatearFecha(pedido.createdAt),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      for (final linea in pedido.lineas)
                        Text('${linea.cantidad} × ${linea.nombreProducto}'),
                      const SizedBox(height: 4),
                      Text('Total estimado: ${formatearPrecio(pedido.total)}'),
                      Text(pedido.direccion),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: ocupado
                                ? null
                                : () => _procesar(
                                    pedido,
                                    widget.pedidoRepository.rechazarPedido,
                                    'Pedido rechazado.',
                                  ),
                            child: const Text('Rechazar'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: ocupado
                                ? null
                                : () => _procesar(
                                    pedido,
                                    widget.pedidoRepository.confirmarPedido,
                                    'Pedido confirmado.',
                                  ),
                            child: ocupado
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Confirmar'),
                          ),
                        ],
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
