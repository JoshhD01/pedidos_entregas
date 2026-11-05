import 'package:flutter/material.dart';

import '../../models/perfil.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/producto_repository.dart';
import '../../widgets/boton_cerrar_sesion.dart';
import '../catalogo/catalogo_vista.dart';

class InicioCliente extends StatelessWidget {
  final Perfil perfil;
  final AuthRepository authRepository;
  final ProductoRepository productoRepository;

  const InicioCliente({
    super.key,
    required this.perfil,
    required this.authRepository,
    required this.productoRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [BotonCerrarSesion(authRepository: authRepository)],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text('Hola, ${perfil.nombre}'),
          ),
          Expanded(
            child: CatalogoVista(productoRepository: productoRepository),
          ),
        ],
      ),
    );
  }
}
