import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  final IconData icono;
  final String mensaje;

  const EmptyView({super.key, required this.icono, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(mensaje, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
