import 'package:flutter/material.dart';

import '../../models/perfil.dart';
import '../../repositories/auth_repository.dart';
import '../../widgets/boton_cerrar_sesion.dart';
import '../../widgets/empty_view.dart';

/// El catálogo se agrega en T8.
class InicioCliente extends StatelessWidget {
  final Perfil perfil;
  final AuthRepository authRepository;

  const InicioCliente({
    super.key,
    required this.perfil,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos y Entregas'),
        actions: [BotonCerrarSesion(authRepository: authRepository)],
      ),
      body: EmptyView(
        icono: Icons.storefront,
        mensaje: 'Hola, ${perfil.nombre}. Aquí verás el catálogo.',
      ),
    );
  }
}
