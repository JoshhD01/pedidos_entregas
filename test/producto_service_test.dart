import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pedidos_entregas/core/errores.dart';
import 'package:pedidos_entregas/services/producto_service.dart';

const url = 'https://ejemplo.test/catalogo';

ProductoService servicio(MockClientHandler respuesta) => ProductoService(
  url,
  cliente: MockClient(respuesta),
  tiempoLimite: const Duration(milliseconds: 50),
);

Matcher apiExceptionCon(String texto) => throwsA(
  isA<ApiException>().having((e) => e.mensaje, 'mensaje', contains(texto)),
);

void main() {
  test('convierte el JSON en productos y conserva las tildes', () async {
    final cuerpo = utf8.encode(
      jsonEncode([
        {
          'id': 'p007',
          'nombre': 'Café frío',
          'categoria': 'Bebidas',
          'descripcion': 'Con hielo',
          'precio': 7500,
        },
      ]),
    );

    final productos = await servicio(
      (_) async => http.Response.bytes(cuerpo, 200),
    ).obtenerProductos();

    expect(productos.single.id, 'p007');
    expect(productos.single.nombre, 'Café frío');
    expect(productos.single.precioReferencia, 7500);
  });

  test('una lista vacía no es un error', () async {
    final productos = await servicio(
      (_) async => http.Response('[]', 200),
    ).obtenerProductos();

    expect(productos, isEmpty);
  });

  test('404 da un mensaje útil', () {
    expect(
      servicio((_) async => http.Response('', 404)).obtenerProductos(),
      apiExceptionCon('No encontramos'),
    );
  });

  test('500 da un mensaje útil', () {
    expect(
      servicio((_) async => http.Response('', 500)).obtenerProductos(),
      apiExceptionCon('servidor'),
    );
  });

  test('otro código no exitoso es un error controlado', () {
    expect(
      servicio((_) async => http.Response('', 403)).obtenerProductos(),
      apiExceptionCon('No se pudo'),
    );
  });

  test('un JSON inválido es un error controlado', () {
    expect(
      servicio((_) async => http.Response('<html>', 200)).obtenerProductos(),
      apiExceptionCon('formato'),
    );
  });

  test('un JSON que no es lista es un error controlado', () {
    expect(
      servicio((_) async => http.Response('{"a":1}', 200)).obtenerProductos(),
      apiExceptionCon('formato'),
    );
  });

  test('un producto incompleto es un error controlado', () {
    expect(
      servicio(
        (_) async => http.Response('[{"id":"p001"}]', 200),
      ).obtenerProductos(),
      apiExceptionCon('formato'),
    );
  });

  test('un producto con id numérico es un error controlado', () {
    expect(
      servicio(
        (_) async => http.Response(
          '[{"id":1,"nombre":"a","categoria":"b",'
          '"descripcion":"c","precio":1}]',
          200,
        ),
      ).obtenerProductos(),
      apiExceptionCon('formato'),
    );
  });

  test('el timeout es un error controlado', () {
    expect(
      servicio((_) async {
        await Future<void>.delayed(const Duration(seconds: 1));
        return http.Response('[]', 200);
      }).obtenerProductos(),
      apiExceptionCon('tardó'),
    );
  });

  test('sin conexión es un error controlado', () {
    expect(
      servicio(
        (_) async => throw const SocketException('sin red'),
      ).obtenerProductos(),
      apiExceptionCon('Sin conexión'),
    );
  });

  test('un fallo del cliente HTTP es un error controlado', () {
    expect(
      servicio(
        (_) async => throw http.ClientException('fallo'),
      ).obtenerProductos(),
      apiExceptionCon('Sin conexión'),
    );
  });
}
