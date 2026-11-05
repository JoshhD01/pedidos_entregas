import 'package:flutter/material.dart';

import '../../models/perfil.dart';
import '../../repositories/auth_repository.dart';
import '../../widgets/boton_cerrar_sesion.dart';
import '../../widgets/empty_view.dart';

/// La bandeja del repartidor se implementa después del sprint.
class InicioRepartidor extends StatelessWidget {
  final Perfil perfil;
  final AuthRepository authRepository;

  const InicioRepartidor({
    super.key,
    required this.perfil,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis entregas'),
        actions: [BotonCerrarSesion(authRepository: authRepository)],
      ),
      body: EmptyView(
        icono: Icons.delivery_dining,
        mensaje: 'Hola, ${perfil.nombre}. Aquí verás tus pedidos asignados.',
      ),
    );
  }
}
