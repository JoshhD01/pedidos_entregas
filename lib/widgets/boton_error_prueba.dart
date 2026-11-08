import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/registro_errores.dart';

/// Solo en debug: envía un error de prueba a Crashlytics.
class BotonErrorPrueba extends StatelessWidget {
  const BotonErrorPrueba({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    return IconButton(
      tooltip: 'Error de prueba',
      icon: const Icon(Icons.bug_report_outlined),
      onPressed: () {
        registrarError(
          StateError('Error de prueba de Crashlytics'),
          StackTrace.current,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de prueba registrado.')),
        );
      },
    );
  }
}
