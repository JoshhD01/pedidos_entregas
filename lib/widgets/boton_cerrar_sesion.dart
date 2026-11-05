import 'package:flutter/material.dart';

import '../repositories/auth_repository.dart';

class BotonCerrarSesion extends StatelessWidget {
  final AuthRepository authRepository;

  const BotonCerrarSesion({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Cerrar sesión',
      onPressed: authRepository.cerrarSesion,
      icon: const Icon(Icons.logout),
    );
  }
}
