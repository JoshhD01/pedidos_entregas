import 'package:flutter_test/flutter_test.dart';
import 'package:pedidos_entregas/models/estado_pedido.dart';
import 'package:pedidos_entregas/models/estado_sync.dart';
import 'package:pedidos_entregas/models/linea_pedido.dart';
import 'package:pedidos_entregas/models/pedido.dart';
import 'package:pedidos_entregas/models/perfil.dart';
import 'package:pedidos_entregas/models/producto.dart';

void main() {
  group('EstadoPedido', () {
    test('convierte todos los estados en ida y vuelta', () {
      for (final estado in EstadoPedido.values) {
        expect(EstadoPedido.fromValor(estado.valor), estado);
      }
    });

    test('usa los nombres del caso', () {
      expect(EstadoPedido.enCamino.valor, 'EN_CAMINO');
    });

    test('un estado desconocido no se interpreta como válido', () {
      expect(() => EstadoPedido.fromValor('APROBADO'), throwsFormatException);
    });

    test('solo entregado, rechazado y cancelado son terminales', () {
      final terminales = EstadoPedido.values.where((e) => e.esTerminal).toSet();
      expect(terminales, {
        EstadoPedido.entregado,
        EstadoPedido.rechazado,
        EstadoPedido.cancelado,
      });
    });
  });

  group('Perfil', () {
    test('lee el rol desde Firestore', () {
      final perfil = Perfil.fromFirestore('uid1', {
        'nombre': 'Ana',
        'email': 'ana@prueba.com',
        'rol': 'operador',
      });
      expect(perfil.uid, 'uid1');
      expect(perfil.rol, Rol.operador);
    });

    test('un rol desconocido es un error, no un rol por defecto', () {
      expect(
        () => Perfil.fromFirestore('uid1', {
          'nombre': 'Ana',
          'email': 'ana@prueba.com',
          'rol': 'admin',
        }),
        throwsFormatException,
      );
    });

    test('un perfil sin rol es un error', () {
      expect(
        () => Perfil.fromFirestore('uid1', {
          'nombre': 'Ana',
          'email': 'ana@prueba.com',
        }),
        throwsFormatException,
      );
    });
  });

  group('Producto', () {
    final json = <String, dynamic>{
      'id': 'p001',
      'nombre': 'Hamburguesa',
      'categoria': 'Comida',
      'descripcion': 'Con queso',
      'precio': 18000,
    };

    test('se crea desde JSON con id String', () {
      final producto = Producto.fromJson(json);
      expect(producto.id, 'p001');
      expect(producto.precioReferencia, 18000);
    });

    test('un id numérico es formato inválido', () {
      expect(
        () => Producto.fromJson({...json, 'id': 1}),
        throwsFormatException,
      );
    });

    test('un campo faltante es formato inválido', () {
      final incompleto = Map<String, dynamic>.from(json)..remove('nombre');
      expect(() => Producto.fromJson(incompleto), throwsFormatException);
    });

    test('un precio negativo es formato inválido', () {
      expect(
        () => Producto.fromJson({...json, 'precio': -1}),
        throwsFormatException,
      );
    });

    test('ProductoOperativo lee precio y stock vigentes', () {
      final operativo = ProductoOperativo.fromFirestore('p001', {
        'nombre': 'Hamburguesa',
        'precio': 19000,
        'stock': 4,
      });
      expect(operativo.precio, 19000);
      expect(operativo.stock, 4);
    });
  });

  group('Pedido', () {
    final fecha = DateTime.utc(2026, 11, 4, 12);

    Pedido pedido({String? codigo, EstadoSync sync = EstadoSync.pendiente}) =>
        Pedido(
          id: 'uuid-1',
          clienteUid: 'cliente1',
          lineas: const [
            LineaPedido(
              productoId: 'p001',
              nombreProducto: 'Hamburguesa',
              cantidad: 2,
              precioUnitario: 18000,
            ),
            LineaPedido(
              productoId: 'p002',
              nombreProducto: 'Gaseosa',
              cantidad: 1,
              precioUnitario: 5000,
            ),
          ],
          direccion: 'Calle 1 # 2-3',
          estado: EstadoPedido.creado,
          createdAt: fecha,
          updatedAt: fecha,
          estadoSync: sync,
          codigoRecepcion: codigo,
        );

    test('el total se calcula con las líneas', () {
      expect(pedido().total, 41000);
    });

    test('solo un pendiente se puede reenviar', () {
      expect(pedido().pendingSync, isTrue);
      expect(pedido(sync: EstadoSync.sincronizado).pendingSync, isFalse);
      expect(pedido(sync: EstadoSync.rechazado).pendingSync, isFalse);
    });

    test('el código de recepción y los campos locales no van a Firestore', () {
      final data = pedido(codigo: '1234').toFirestore();
      expect(data.containsKey('codigoRecepcion'), isFalse);
      expect(data.containsKey('estadoSync'), isFalse);
      expect(data.containsKey('lastError'), isFalse);
      expect(data.values, isNot(contains('1234')));
    });

    test('ida y vuelta con Firestore conserva los datos', () {
      final copia = Pedido.fromFirestore('uuid-1', pedido().toFirestore());
      expect(copia.id, 'uuid-1');
      expect(copia.clienteUid, 'cliente1');
      expect(copia.lineas, hasLength(2));
      expect(copia.lineas.first.nombreProducto, 'Hamburguesa');
      expect(copia.total, 41000);
      expect(copia.estado, EstadoPedido.creado);
      expect(copia.repartidorUid, isNull);
      expect(copia.createdAt.toUtc(), fecha);
      expect(copia.estadoSync, EstadoSync.sincronizado);
    });

    test('un documento con un estado desconocido es un error', () {
      final data = pedido().toFirestore()..['estado'] = 'APROBADO';
      expect(() => Pedido.fromFirestore('uuid-1', data), throwsFormatException);
    });

    test('un documento sin líneas válidas es formato inválido', () {
      final data = pedido().toFirestore()..['lineas'] = 'no es una lista';
      expect(() => Pedido.fromFirestore('uuid-1', data), throwsFormatException);
    });

    test('una línea sin nombre de producto es formato inválido', () {
      expect(
        () => LineaPedido.fromMap({
          'productoId': 'p001',
          'cantidad': 1,
          'precioUnitario': 5000,
        }),
        throwsFormatException,
      );
    });

    test('una fecha que no es Timestamp es formato inválido', () {
      final data = pedido().toFirestore()..['createdAt'] = '2026-11-04';
      expect(() => Pedido.fromFirestore('uuid-1', data), throwsFormatException);
    });
  });
}
