import 'package:flutter/material.dart';

import '../../models/perfil.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/entrega_repository.dart';
import '../../widgets/boton_cerrar_sesion.dart';
import '../../widgets/boton_error_prueba.dart';
import '../repartidor/bandeja_repartidor.dart';

class InicioRepartidor extends StatelessWidget {
  final Perfil perfil;
  final AuthRepository authRepository;
  final EntregaRepository entregaRepository;

  const InicioRepartidor({
    super.key,
    required this.perfil,
    required this.authRepository,
    required this.entregaRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis entregas'),
        actions: [
          const BotonErrorPrueba(),
          BotonCerrarSesion(authRepository: authRepository),
        ],
      ),
      body: BandejaRepartidor(
        repartidorUid: perfil.uid,
        nombre: perfil.nombre,
        entregaRepository: entregaRepository,
      ),
    );
  }
}
