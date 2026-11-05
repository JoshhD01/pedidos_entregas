import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedidos_entregas/core/errores.dart';
import 'package:pedidos_entregas/models/producto.dart';
import 'package:pedidos_entregas/repositories/producto_repository.dart';
import 'package:pedidos_entregas/screens/catalogo/catalogo_vista.dart';
import 'package:pedidos_entregas/screens/catalogo/producto_detalle_screen.dart';

const hamburguesa = Producto(
  id: 'p001',
  nombre: 'Hamburguesa',
  categoria: 'Comida',
  descripcion: 'Con queso y lechuga',
  precioReferencia: 18000,
);

class FakeRepositorio implements ProductoRepository {
  Object? error;
  ResultadoCatalogo resultado = const ResultadoCatalogo([hamburguesa]);
  Completer<void>? espera;
  int peticiones = 0;

  @override
  Future<ResultadoCatalogo> obtenerCatalogo() async {
    peticiones++;
    await espera?.future;
    if (error != null) throw error!;
    return resultado;
  }

  @override
  Future<ProductoOperativo?> obtenerOperativo(String productoId) async => null;
}

Future<void> abrir(WidgetTester tester, FakeRepositorio repositorio) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: CatalogoVista(productoRepository: repositorio)),
    ),
  );
}

void main() {
  testWidgets('muestra carga y luego los productos con precio', (tester) async {
    final repositorio = FakeRepositorio()..espera = Completer<void>();
    await abrir(tester, repositorio);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repositorio.espera!.complete();
    await tester.pumpAndSettle();

    expect(find.text('Hamburguesa'), findsOneWidget);
    expect(find.text('Comida'), findsOneWidget);
    expect(find.text(r'$ 18.000 COP'), findsOneWidget);
  });

  testWidgets('catálogo vacío muestra su mensaje, no un error', (tester) async {
    final repositorio = FakeRepositorio()
      ..resultado = const ResultadoCatalogo([]);
    await abrir(tester, repositorio);
    await tester.pumpAndSettle();

    expect(find.text('No hay productos en el catálogo.'), findsOneWidget);
    expect(find.text('Reintentar'), findsNothing);
  });

  testWidgets('un error conocido muestra su mensaje y reintentar', (
    tester,
  ) async {
    final repositorio = FakeRepositorio()
      ..error = const ApiException('Sin conexión a internet.');
    await abrir(tester, repositorio);
    await tester.pumpAndSettle();

    expect(find.text('Sin conexión a internet.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('un error inesperado no muestra texto técnico', (tester) async {
    final repositorio = FakeRepositorio()..error = StateError('traza técnica');
    await abrir(tester, repositorio);
    await tester.pumpAndSettle();

    expect(find.textContaining('traza técnica'), findsNothing);
    expect(find.text('No se pudo cargar el catálogo.'), findsOneWidget);
  });

  testWidgets('reintentar hace una nueva petición y carga', (tester) async {
    final repositorio = FakeRepositorio()
      ..error = const ApiException('Sin conexión a internet.');
    await abrir(tester, repositorio);
    await tester.pumpAndSettle();
    expect(repositorio.peticiones, 1);

    repositorio.error = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(repositorio.peticiones, 2);
    expect(find.text('Hamburguesa'), findsOneWidget);
  });

  testWidgets('reconstruir la pantalla no duplica la petición', (tester) async {
    final repositorio = FakeRepositorio();
    await abrir(tester, repositorio);
    await tester.pumpAndSettle();

    await abrir(tester, repositorio);
    await tester.pumpAndSettle();

    expect(repositorio.peticiones, 1);
  });

  testWidgets('la copia guardada se muestra con aviso y reintentar', (
    tester,
  ) async {
    final repositorio = FakeRepositorio()
      ..resultado = const ResultadoCatalogo([
        hamburguesa,
      ], avisoCopiaLocal: 'Sin conexión a internet.');
    await abrir(tester, repositorio);
    await tester.pumpAndSettle();

    expect(find.text('Hamburguesa'), findsOneWidget);
    expect(find.textContaining('última copia guardada'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('tocar un producto abre su detalle', (tester) async {
    await abrir(tester, FakeRepositorio());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hamburguesa'));
    await tester.pumpAndSettle();

    expect(find.byType(ProductoDetalleScreen), findsOneWidget);
    expect(find.text('Con queso y lechuga'), findsOneWidget);
    expect(find.text('Precio de referencia'), findsOneWidget);
  });

  testWidgets('salir antes de que responda no causa error', (tester) async {
    final repositorio = FakeRepositorio()..espera = Completer<void>();
    await abrir(tester, repositorio);
    await tester.pump();

    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    repositorio.espera!.complete();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
