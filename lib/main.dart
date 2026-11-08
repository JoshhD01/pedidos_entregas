import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'local/app_database.dart';
import 'local/pedido_local_data_source.dart';
import 'local/producto_local_data_source.dart';
import 'models/perfil.dart';
import 'remote/auth_remote_data_source.dart';
import 'remote/entrega_remote_data_source.dart';
import 'remote/pedido_remote_data_source.dart';
import 'remote/perfil_remote_data_source.dart';
import 'remote/producto_remote_data_source.dart';
import 'repositories/auth_repository.dart';
import 'repositories/entrega_repository.dart';
import 'repositories/pedido_repository.dart';
import 'repositories/producto_repository.dart';
import 'screens/auth/login_screen.dart';
import 'screens/inicio/inicio_segun_rol.dart';
import 'services/producto_service.dart';
import 'widgets/boton_cerrar_sesion.dart';
import 'widgets/error_view.dart';

const catalogoUrl = 'https://dummyjson.com/c/59f3-0f90-41f6-952e';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authRepository = FirebaseAuthRepository(
    auth: AuthRemoteDataSource(FirebaseAuth.instance),
    perfiles: PerfilRemoteDataSource(FirebaseFirestore.instance),
  );

  final db = AppDatabase();

  final productoRepository = ProductoRepositoryImpl(
    service: ProductoService(catalogoUrl),
    local: ProductoLocalDataSource(db),
    remote: ProductoRemoteDataSource(FirebaseFirestore.instance),
  );

  final pedidoRepository = PedidoRepositoryImpl(
    local: PedidoLocalDataSource(db),
    remote: PedidoRemoteDataSource(FirebaseFirestore.instance),
  );

  final entregaRepository = EntregaRepositoryImpl(
    remote: EntregaRemoteDataSource(FirebaseFirestore.instance),
  );

  runApp(
    PedidosEntregasApp(
      authRepository: authRepository,
      productoRepository: productoRepository,
      pedidoRepository: pedidoRepository,
      entregaRepository: entregaRepository,
    ),
  );
}

class PedidosEntregasApp extends StatelessWidget {
  final AuthRepository authRepository;
  final ProductoRepository productoRepository;
  final PedidoRepository pedidoRepository;
  final EntregaRepository entregaRepository;

  const PedidosEntregasApp({
    super.key,
    required this.authRepository,
    required this.productoRepository,
    required this.pedidoRepository,
    required this.entregaRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pedidos y Entregas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: RaizSesion(
        authRepository: authRepository,
        productoRepository: productoRepository,
        pedidoRepository: pedidoRepository,
        entregaRepository: entregaRepository,
      ),
    );
  }
}

/// Decide qué mostrar según la sesión. Restaura una sesión existente sola.
class RaizSesion extends StatefulWidget {
  final AuthRepository authRepository;
  final ProductoRepository productoRepository;
  final PedidoRepository pedidoRepository;
  final EntregaRepository entregaRepository;

  const RaizSesion({
    super.key,
    required this.authRepository,
    required this.productoRepository,
    required this.pedidoRepository,
    required this.entregaRepository,
  });

  @override
  State<RaizSesion> createState() => _RaizSesionState();
}

class _RaizSesionState extends State<RaizSesion> {
  // Se crea una vez: si no, cada reconstrucción se volvería a suscribir.
  late final Stream<String?> _sesion = widget.authRepository.observarSesion();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: _sesion,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final uid = snapshot.data;
        if (uid == null) {
          return LoginScreen(authRepository: widget.authRepository);
        }
        // La llave crea una pantalla nueva al cambiar de cuenta, para que nunca
        // se muestre el perfil de la cuenta anterior.
        return CargaPerfil(
          key: ValueKey(uid),
          uid: uid,
          authRepository: widget.authRepository,
          productoRepository: widget.productoRepository,
          pedidoRepository: widget.pedidoRepository,
          entregaRepository: widget.entregaRepository,
        );
      },
    );
  }
}

/// Consulta el perfil. Sin un perfil válido no se entra a ninguna pantalla.
class CargaPerfil extends StatefulWidget {
  final String uid;
  final AuthRepository authRepository;
  final ProductoRepository productoRepository;
  final PedidoRepository pedidoRepository;
  final EntregaRepository entregaRepository;

  const CargaPerfil({
    super.key,
    required this.uid,
    required this.authRepository,
    required this.productoRepository,
    required this.pedidoRepository,
    required this.entregaRepository,
  });

  @override
  State<CargaPerfil> createState() => _CargaPerfilState();
}

class _CargaPerfilState extends State<CargaPerfil> {
  // Se guarda para que reconstruir la pantalla no repita la consulta.
  late Future<Perfil> _perfil = widget.authRepository.obtenerPerfil(widget.uid);

  void _reintentar() {
    setState(() {
      _perfil = widget.authRepository.obtenerPerfil(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Perfil>(
      future: _perfil,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final perfil = snapshot.data;
        if (snapshot.hasError || perfil == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Pedidos y Entregas'),
              actions: [
                BotonCerrarSesion(authRepository: widget.authRepository),
              ],
            ),
            body: ErrorView(
              mensaje: 'No pudimos cargar tu perfil',
              onReintentar: _reintentar,
            ),
          );
        }
        return InicioSegunRol(
          perfil: perfil,
          authRepository: widget.authRepository,
          productoRepository: widget.productoRepository,
          pedidoRepository: widget.pedidoRepository,
          entregaRepository: widget.entregaRepository,
        );
      },
    );
  }
}
