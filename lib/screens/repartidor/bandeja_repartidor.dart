import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/errores.dart';
import '../../core/formato.dart';
import '../../core/registro_errores.dart';
import '../../models/estado_pedido.dart';
import '../../models/pedido.dart';
import '../../repositories/entrega_repository.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../pedidos/mis_pedidos_screen.dart' show etiquetaEstado;

class BandejaRepartidor extends StatefulWidget {
  final String repartidorUid;
  final String nombre;
  final EntregaRepository entregaRepository;

  const BandejaRepartidor({
    super.key,
    required this.repartidorUid,
    required this.nombre,
    required this.entregaRepository,
  });

  @override
  State<BandejaRepartidor> createState() => _BandejaRepartidorState();
}

class _BandejaRepartidorState extends State<BandejaRepartidor> {
  late Stream<List<Pedido>> _pedidos = _observar();

  Stream<List<Pedido>> _observar() =>
      widget.entregaRepository.observarAsignados(widget.repartidorUid);

  final _procesando = <String>{};

  void _reintentar() => setState(() => _pedidos = _observar());

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
      mensaje = 'Sin conexión. Intenta de nuevo.';
    } catch (error, stack) {
      registrarError(error, stack);
      mensaje = 'No se pudo actualizar el pedido.';
    }
    if (!mounted) return;
    setState(() => _procesando.remove(pedido.id));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _iniciarRecorrido(Pedido pedido) => _procesar(
    pedido,
    () => widget.entregaRepository.iniciarRecorrido(
      pedido.id,
      widget.repartidorUid,
    ),
    'Recorrido iniciado.',
  );

  Future<void> _entregar(Pedido pedido) async {
    final codigo = await showDialog<String>(
      context: context,
      builder: (_) => const _DialogoCodigo(),
    );
    if (codigo == null) return;
    await _procesar(
      pedido,
      () => widget.entregaRepository.entregar(
        pedido.id,
        widget.repartidorUid,
        codigo,
      ),
      'Pedido entregado.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Pedido>>(
      stream: _pedidos,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorView(
            mensaje: 'No se pudieron cargar tus entregas.',
            onReintentar: _reintentar,
          );
        }
        final pedidos = snapshot.data;
        if (pedidos == null) return const LoadingView();
        if (pedidos.isEmpty) {
          return EmptyView(
            icono: Icons.delivery_dining,
            mensaje: 'Hola, ${widget.nombre}. No tienes pedidos asignados.',
          );
        }

        final enCurso = pedidos
            .where((pedido) => pedido.estado == EstadoPedido.enCamino)
            .toList();
        final asignados = pedidos
            .where((pedido) => pedido.estado == EstadoPedido.listo)
            .toList();

        return ListView(
          padding: EdgeInsets.fromLTRB(
            12,
            12,
            12,
            12 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            if (enCurso.isNotEmpty) ...[
              const _Titulo('En curso'),
              for (final pedido in enCurso)
                _EntregaCard(
                  pedido: pedido,
                  textoBoton: 'Entregar',
                  ocupado: _procesando.contains(pedido.id),
                  onPressed: () => _entregar(pedido),
                ),
            ],
            if (asignados.isNotEmpty) ...[
              const _Titulo('Asignados'),
              for (final pedido in asignados)
                _EntregaCard(
                  pedido: pedido,
                  textoBoton: 'Iniciar recorrido',
                  ocupado: _procesando.contains(pedido.id),
                  onPressed: () => _iniciarRecorrido(pedido),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _Titulo extends StatelessWidget {
  final String texto;

  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _EntregaCard extends StatelessWidget {
  final Pedido pedido;
  final String? textoBoton;
  final bool ocupado;
  final VoidCallback? onPressed;

  const _EntregaCard({
    required this.pedido,
    this.textoBoton,
    this.ocupado = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
            Text('Total: ${formatearPrecio(pedido.total)}'),
            Text(pedido.direccion),
            if (textoBoton != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: ocupado ? null : onPressed,
                  child: Text(ocupado ? 'Guardando...' : textoBoton!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DialogoCodigo extends StatefulWidget {
  const _DialogoCodigo();

  @override
  State<_DialogoCodigo> createState() => _DialogoCodigoState();
}

class _DialogoCodigoState extends State<_DialogoCodigo> {
  final _formulario = GlobalKey<FormState>();
  final _codigo = TextEditingController();

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (_formulario.currentState!.validate()) {
      Navigator.of(context).pop(_codigo.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Código de recepción'),
      content: Form(
        key: _formulario,
        child: TextFormField(
          controller: _codigo,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Código que dicta el cliente',
          ),
          validator: (valor) => valor != null && valor.length == 6
              ? null
              : 'El código tiene 6 dígitos.',
          onFieldSubmitted: (_) => _confirmar(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _confirmar, child: const Text('Entregar')),
      ],
    );
  }
}
