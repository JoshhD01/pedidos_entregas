import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'remote/auth_remote_data_source.dart';
import 'repositories/auth_repository.dart';
import 'screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authRepository = FirebaseAuthRepository(
    AuthRemoteDataSource(FirebaseAuth.instance),
  );

  runApp(PedidosEntregasApp(authRepository: authRepository));
}

class PedidosEntregasApp extends StatelessWidget {
  final AuthRepository authRepository;

  const PedidosEntregasApp({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pedidos y Entregas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: RaizSesion(authRepository: authRepository),
    );
  }
}

/// Decide qué mostrar según la sesión. Restaura una sesión existente sola.
class RaizSesion extends StatefulWidget {
  final AuthRepository authRepository;

  const RaizSesion({super.key, required this.authRepository});

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
        if (snapshot.data == null) {
          return LoginScreen(authRepository: widget.authRepository);
        }
        return InicioTemporal(authRepository: widget.authRepository);
      },
    );
  }
}

/// Pantalla temporal hasta que exista el inicio según el rol (T7).
class InicioTemporal extends StatelessWidget {
  final AuthRepository authRepository;

  const InicioTemporal({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos y Entregas'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: authRepository.cerrarSesion,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delivery_dining, size: 72, color: colors.primary),
            const SizedBox(height: 16),
            const Text('Sesión iniciada'),
          ],
        ),
      ),
    );
  }
}
