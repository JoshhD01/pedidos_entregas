import 'package:flutter/material.dart';

import '../../models/perfil.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/pedido_repository.dart';
import '../../repositories/producto_repository.dart';
import 'inicio_cliente.dart';
import 'inicio_operador.dart';
import 'inicio_repartidor.dart';

/// Cada rol llega solo a su inicio. Sin caso por defecto: si se agrega un rol,
/// el compilador obliga a decidir qué pantalla le corresponde.
class InicioSegunRol extends StatelessWidget {
  final Perfil perfil;
  final AuthRepository authRepository;
  final ProductoRepository productoRepository;
  final PedidoRepository pedidoRepository;

  const InicioSegunRol({
    super.key,
    required this.perfil,
    required this.authRepository,
    required this.productoRepository,
    required this.pedidoRepository,
  });

  @override
  Widget build(BuildContext context) {
    return switch (perfil.rol) {
      Rol.cliente => InicioCliente(
        perfil: perfil,
        authRepository: authRepository,
        productoRepository: productoRepository,
        pedidoRepository: pedidoRepository,
      ),
      Rol.operador => InicioOperador(
        perfil: perfil,
        authRepository: authRepository,
        pedidoRepository: pedidoRepository,
      ),
      Rol.repartidor => InicioRepartidor(
        perfil: perfil,
        authRepository: authRepository,
      ),
    };
  }
}
