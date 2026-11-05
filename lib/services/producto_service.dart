import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/errores.dart';
import '../models/producto.dart';

/// Pide el catálogo por HTTP y lo convierte en modelos.
/// Todo fallo llega como `ApiException` con un mensaje para el usuario.
class ProductoService {
  final String url;
  final http.Client cliente;
  final Duration tiempoLimite;

  ProductoService(
    this.url, {
    http.Client? cliente,
    this.tiempoLimite = const Duration(seconds: 10),
  }) : cliente = cliente ?? http.Client();

  Future<List<Producto>> obtenerProductos() async {
    try {
      final respuesta = await cliente.get(Uri.parse(url)).timeout(tiempoLimite);

      if (respuesta.statusCode == 404) {
        throw const ApiException('No encontramos el catálogo.');
      }
      if (respuesta.statusCode >= 500) {
        throw const ApiException(
          'El servidor del catálogo tiene problemas. Inténtalo más tarde.',
        );
      }
      if (respuesta.statusCode != 200) {
        throw const ApiException('No se pudo obtener el catálogo.');
      }

      // bodyBytes con utf8: `body` puede dañar las tildes según el servidor.
      final datos = jsonDecode(utf8.decode(respuesta.bodyBytes)) as List;
      return datos
          .map(
            (item) => Producto.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } on TimeoutException {
      throw const ApiException('El catálogo tardó demasiado en responder.');
    } on SocketException {
      throw const ApiException('Sin conexión a internet.');
    } on http.ClientException {
      throw const ApiException('Sin conexión con el catálogo.');
    } on FormatException {
      throw const ApiException('El catálogo llegó con un formato inválido.');
    } on TypeError {
      throw const ApiException('El catálogo llegó con un formato inválido.');
    }
  }
}
