import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PedidosEntregasApp());
}

class PedidosEntregasApp extends StatelessWidget {
  const PedidosEntregasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pedidos y Entregas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const InicioTemporal(),
    );
  }
}

/// Pantalla temporal hasta que exista la autenticación (T5).
class InicioTemporal extends StatelessWidget {
  const InicioTemporal({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos y Entregas'),
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delivery_dining, size: 72, color: colors.primary),
            const SizedBox(height: 16),
            const Text('Base del proyecto lista'),
          ],
        ),
      ),
    );
  }
}
