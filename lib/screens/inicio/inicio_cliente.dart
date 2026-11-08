import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/registro_errores.dart';
import '../../models/linea_pedido.dart';
import '../../models/pedido.dart';
import '../../models/perfil.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/pedido_repository.dart';
import '../../repositories/producto_repository.dart';
import '../../widgets/boton_cerrar_sesion.dart';
import '../catalogo/catalogo_vista.dart';
import '../pedidos/carrito_screen.dart';
import '../pedidos/mis_pedidos_screen.dart';

class InicioCliente extends StatefulWidget {
  final Perfil perfil;
  final AuthRepository authRepository;
  final ProductoRepository productoRepository;
  final PedidoRepository pedidoRepository;

  const InicioCliente({
    super.key,
    required this.perfil,
    required this.authRepository,
    required this.productoRepository,
    required this.pedidoRepository,
  });

  @override
  State<InicioCliente> createState() => _InicioClienteState();
}

class _InicioClienteState extends State<InicioCliente> {
  final _carrito = ValueNotifier<List<LineaPedido>>(const []);
  late final StreamSubscription<void> _seguimiento;

  @override
  void initState() {
    super.initState();
    // Toda la sesión del cliente: Mis pedidos refleja lo que hacen los otros roles.
    _seguimiento = widget.pedidoRepository
        .seguirMisPedidos(widget.perfil.uid)
        .listen(null, onError: registrarError);
  }

  @override
  void dispose() {
    _seguimiento.cancel();
    _carrito.dispose();
    super.dispose();
  }

  /// Máximo 5 productos diferentes; si ya está, se reemplaza la cantidad.
  void _agregar(LineaPedido nueva) {
    final lineas = _carrito.value;
    final existe = lineas.any((l) => l.productoId == nueva.productoId);
    final mensajero = ScaffoldMessenger.of(context);

    if (!existe && lineas.length >= PedidoRepositoryImpl.maxProductos) {
      mensajero.showSnackBar(
        const SnackBar(
          content: Text(
            'Un pedido admite máximo ${PedidoRepositoryImpl.maxProductos} '
            'productos diferentes.',
          ),
        ),
      );
      return;
    }
    _carrito.value = [
      for (final linea in lineas)
        if (linea.productoId != nueva.productoId) linea,
      nueva,
    ];
    mensajero.showSnackBar(
      SnackBar(content: Text('${nueva.nombreProducto} en el carrito.')),
    );
  }

  void _abrirMisPedidos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MisPedidosScreen(
          pedidoRepository: widget.pedidoRepository,
          clienteUid: widget.perfil.uid,
        ),
      ),
    );
  }

  Future<void> _abrirCarrito() async {
    final creado = await Navigator.push<Pedido>(
      context,
      MaterialPageRoute(
        builder: (_) => CarritoScreen(
          carrito: _carrito,
          pedidoRepository: widget.pedidoRepository,
          clienteUid: widget.perfil.uid,
        ),
      ),
    );
    if (creado == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Pedido creado.'),
        action: SnackBarAction(label: 'Ver', onPressed: _abrirMisPedidos),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          IconButton(
            tooltip: 'Mis pedidos',
            onPressed: _abrirMisPedidos,
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          ValueListenableBuilder<List<LineaPedido>>(
            valueListenable: _carrito,
            builder: (context, lineas, _) => IconButton(
              tooltip: 'Carrito',
              onPressed: _abrirCarrito,
              icon: Badge(
                isLabelVisible: lineas.isNotEmpty,
                label: Text('${lineas.length}'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ),
          BotonCerrarSesion(authRepository: widget.authRepository),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text('Hola, ${widget.perfil.nombre}'),
          ),
          Expanded(
            child: CatalogoVista(
              productoRepository: widget.productoRepository,
              onAgregar: _agregar,
            ),
          ),
        ],
      ),
    );
  }
}
