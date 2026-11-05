import 'package:flutter/material.dart';

import '../../models/perfil.dart';
import '../../repositories/auth_repository.dart';
import '../../widgets/boton_cerrar_sesion.dart';
import '../../widgets/empty_view.dart';

/// La bandeja del operador la implementa Tomás.
class InicioOperador extends StatelessWidget {
  final Perfil perfil;
  final AuthRepository authRepository;

  const InicioOperador({
    super.key,
    required this.perfil,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bandeja del operador'),
        actions: [BotonCerrarSesion(authRepository: authRepository)],
      ),
      body: EmptyView(
        icono: Icons.inbox_outlined,
        mensaje: 'Hola, ${perfil.nombre}. Aquí verás los pedidos por revisar.',
      ),
    );
  }
}
