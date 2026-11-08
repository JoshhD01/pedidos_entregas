import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedidos_entregas/core/registro_errores.dart';
import 'package:pedidos_entregas/widgets/boton_error_prueba.dart';

void main() {
  test('sin Firebase inicializado registrar un error no falla', () {
    registrarError(StateError('prueba'), StackTrace.current);
  });

  testWidgets('en debug el botón de prueba registra y avisa', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(appBar: AppBar(actions: const [BotonErrorPrueba()])),
      ),
    );

    await tester.tap(find.byTooltip('Error de prueba'));
    await tester.pump();

    expect(find.text('Error de prueba registrado.'), findsOneWidget);
  });
}
