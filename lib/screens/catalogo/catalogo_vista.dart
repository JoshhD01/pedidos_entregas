import 'package:flutter/material.dart';

import '../../core/errores.dart';
import '../../models/linea_pedido.dart';
import '../../models/producto.dart';
import '../../repositories/producto_repository.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import 'producto_card.dart';
import 'producto_detalle_screen.dart';

class CatalogoVista extends StatefulWidget {
  final ProductoRepository productoRepository;

  final ValueChanged<LineaPedido>? onAgregar;

  const CatalogoVista({
    super.key,
    required this.productoRepository,
    this.onAgregar,
  });

  @override
  State<CatalogoVista> createState() => _CatalogoVistaState();
}

class _CatalogoVistaState extends State<CatalogoVista> {
  // Se guarda para que reconstruir la pantalla no repita la petición.
  late Future<ResultadoCatalogo> _catalogo = widget.productoRepository
      .obtenerCatalogo();

  void _reintentar() {
    setState(() {
      _catalogo = widget.productoRepository.obtenerCatalogo();
    });
  }

  void _abrirDetalle(Producto producto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductoDetalleScreen(
          producto: producto,
          onAgregar: widget.onAgregar,
        ),
      ),
    );
  }

  /// Solo se muestra el mensaje de errores conocidos, nunca una traza técnica.
  String _mensajeDeError(Object? error) {
    if (error is ApiException) return error.mensaje;
    return 'No se pudo cargar el catálogo.';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ResultadoCatalogo>(
      future: _catalogo,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }
        final resultado = snapshot.data;
        if (snapshot.hasError || resultado == null) {
          return ErrorView(
            mensaje: _mensajeDeError(snapshot.error),
            onReintentar: _reintentar,
          );
        }
        if (resultado.productos.isEmpty) {
          return const EmptyView(
            icono: Icons.storefront,
            mensaje: 'No hay productos en el catálogo.',
          );
        }

        return Column(
          children: [
            if (resultado.avisoCopiaLocal != null)
              MaterialBanner(
                content: Text(
                  '${resultado.avisoCopiaLocal} '
                  'Mostrando la última copia guardada.',
                ),
                actions: [
                  TextButton(
                    onPressed: _reintentar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            Expanded(
              child: ListView.builder(
                // El margen inferior evita que la barra de gestos tape la última tarjeta.
                padding: EdgeInsets.fromLTRB(
                  12,
                  12,
                  12,
                  12 + MediaQuery.paddingOf(context).bottom,
                ),
                itemCount: resultado.productos.length,
                itemBuilder: (context, indice) {
                  final producto = resultado.productos[indice];
                  return ProductoCard(
                    producto: producto,
                    onTap: () => _abrirDetalle(producto),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
