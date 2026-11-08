import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedidos_entregas/core/errores.dart';
import 'package:pedidos_entregas/main.dart';
import 'package:pedidos_entregas/models/estado_pedido.dart';
import 'package:pedidos_entregas/models/estado_sync.dart';
import 'package:pedidos_entregas/models/pedido.dart';
import 'package:pedidos_entregas/models/perfil.dart';
import 'package:pedidos_entregas/models/producto.dart';
import 'package:pedidos_entregas/repositories/auth_repository.dart';
import 'package:pedidos_entregas/repositories/entrega_repository.dart';
import 'package:pedidos_entregas/repositories/pedido_repository.dart';
import 'package:pedidos_entregas/repositories/producto_repository.dart';
import 'package:pedidos_entregas/screens/auth/login_screen.dart';
import 'package:pedidos_entregas/screens/inicio/inicio_cliente.dart';
import 'package:pedidos_entregas/screens/inicio/inicio_operador.dart';
import 'package:pedidos_entregas/screens/inicio/inicio_repartidor.dart';

class FakeAuthRepository implements AuthRepository {
  final sesion = StreamController<String?>.broadcast();
  Object? errorAlIngresar;
  Object? errorAlRegistrar;
  Completer<void>? espera;
  int intentosIngreso = 0;
  int intentosRegistro = 0;
  int cierresSesion = 0;
  int consultasPerfil = 0;
  Object? errorPerfil;
  Rol rol = Rol.cliente;

  @override
  Stream<String?> observarSesion() => sesion.stream;

  @override
  Future<void> iniciarSesion({
    required String email,
    required String password,
  }) async {
    intentosIngreso++;
    await espera?.future;
    if (errorAlIngresar != null) throw errorAlIngresar!;
    sesion.add('uid1');
  }

  @override
  Future<void> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async {
    intentosRegistro++;
    if (errorAlRegistrar != null) throw errorAlRegistrar!;
    sesion.add('uid1');
  }

  @override
  Future<void> cerrarSesion() async {
    cierresSesion++;
    sesion.add(null);
  }

  @override
  Future<Perfil> obtenerPerfil(String uid) async {
    consultasPerfil++;
    if (errorPerfil != null) throw errorPerfil!;
    return Perfil(uid: uid, nombre: 'Nombre $uid', email: 'a@b.co', rol: rol);
  }
}

class FakeProductoRepository implements ProductoRepository {
  @override
  Future<ResultadoCatalogo> obtenerCatalogo() async =>
      const ResultadoCatalogo([]);

  @override
  Future<ProductoOperativo?> obtenerOperativo(String productoId) async => null;
}

class FakePedidoRepository implements PedidoRepository {
  List<Pedido> bandeja = const [];
  List<Perfil> repartidores = const [];
  final llamadas = <String>[];

  @override
  Stream<List<Pedido>> observarBandejaOperador() => Stream.value(bandeja);

  @override
  Future<List<Perfil>> listarRepartidores() async => repartidores;

  @override
  Stream<void> seguirMisPedidos(String clienteUid) => const Stream.empty();

  @override
  Future<void> prepararPedido(String pedidoId) async =>
      llamadas.add('preparar $pedidoId');

  @override
  Future<void> marcarListo(String pedidoId) async =>
      llamadas.add('listo $pedidoId');

  @override
  Future<void> asignarRepartidor(String pedidoId, String repartidorUid) async =>
      llamadas.add('asignar $pedidoId $repartidorUid');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeEntregaRepository implements EntregaRepository {
  @override
  Stream<List<Pedido>> observarAsignados(String repartidorUid) =>
      Stream.value(const []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget app(FakeAuthRepository auth) => PedidosEntregasApp(
  authRepository: auth,
  productoRepository: FakeProductoRepository(),
  pedidoRepository: FakePedidoRepository(),
  entregaRepository: FakeEntregaRepository(),
);

Future<void> abrirApp(WidgetTester tester, FakeAuthRepository auth) async {
  await tester.pumpWidget(app(auth));
  auth.sesion.add(null);
  await tester.pump();
  await tester.pump();
}

Future<void> llenarLogin(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Correo'),
    'a@b.co',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Contraseña'),
    'secreta1',
  );
}

void main() {
  group('mensajeDeErrorAuth', () {
    test('cubre los errores que piden los lineamientos', () {
      expect(mensajeDeErrorAuth('invalid-credential'), contains('incorrectos'));
      expect(mensajeDeErrorAuth('invalid-email'), contains('no es válido'));
      expect(mensajeDeErrorAuth('weak-password'), contains('rechazada'));
      expect(mensajeDeErrorAuth('email-already-in-use'), contains('Ya existe'));
      expect(
        mensajeDeErrorAuth('network-request-failed'),
        contains('Sin conexión'),
      );
    });

    test('un código desconocido no muestra detalles técnicos', () {
      final mensaje = mensajeDeErrorAuth('internal-error-xyz');
      expect(mensaje, isNot(contains('internal')));
    });
  });

  group('sesión', () {
    testWidgets('sin sesión muestra el login', (tester) async {
      await abrirApp(tester, FakeAuthRepository());
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('con sesión entra sin pedir login y se puede cerrar', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      await tester.pumpWidget(app(auth));
      auth.sesion.add('uid1');
      await tester.pumpAndSettle();
      expect(find.textContaining('Hola, Nombre uid1'), findsOneWidget);

      await tester.tap(find.byTooltip('Cerrar sesión'));
      await tester.pump();
      await tester.pump();
      expect(auth.cierresSesion, 1);
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('perfil', () {
    Future<void> abrirConSesion(
      WidgetTester tester,
      FakeAuthRepository auth,
    ) async {
      await tester.pumpWidget(app(auth));
      auth.sesion.add('uid1');
      await tester.pumpAndSettle();
    }

    testWidgets('el cliente llega solo a su inicio', (tester) async {
      final auth = FakeAuthRepository()..rol = Rol.cliente;
      await abrirConSesion(tester, auth);

      expect(find.byType(InicioCliente), findsOneWidget);
      expect(find.byType(InicioOperador), findsNothing);
      expect(find.byType(InicioRepartidor), findsNothing);
    });

    testWidgets('el operador llega solo a su inicio', (tester) async {
      final auth = FakeAuthRepository()..rol = Rol.operador;
      await abrirConSesion(tester, auth);

      expect(find.byType(InicioOperador), findsOneWidget);
      expect(find.byType(InicioCliente), findsNothing);
      expect(find.byType(InicioRepartidor), findsNothing);
    });

    testWidgets('el repartidor llega solo a su inicio', (tester) async {
      final auth = FakeAuthRepository()..rol = Rol.repartidor;
      await abrirConSesion(tester, auth);

      expect(find.byType(InicioRepartidor), findsOneWidget);
      expect(find.byType(InicioCliente), findsNothing);
      expect(find.byType(InicioOperador), findsNothing);
    });

    for (final rol in Rol.values) {
      testWidgets('cerrar sesión funciona desde el inicio de ${rol.valor}', (
        tester,
      ) async {
        final auth = FakeAuthRepository()..rol = rol;
        await abrirConSesion(tester, auth);

        await tester.tap(find.byTooltip('Cerrar sesión'));
        await tester.pumpAndSettle();

        expect(auth.cierresSesion, 1);
        expect(find.byType(LoginScreen), findsOneWidget);
      });
    }

    testWidgets('al cambiar a una cuenta de otro rol cambia el inicio', (
      tester,
    ) async {
      final auth = FakeAuthRepository()..rol = Rol.operador;
      await abrirConSesion(tester, auth);
      expect(find.byType(InicioOperador), findsOneWidget);

      auth.rol = Rol.cliente;
      auth.sesion.add('uid2');
      await tester.pumpAndSettle();

      expect(find.byType(InicioOperador), findsNothing);
      expect(find.byType(InicioCliente), findsOneWidget);
    });

    testWidgets('un rol desconocido no entra: error con reintentar', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..errorPerfil = const FormatException('Rol desconocido: admin');
      await abrirConSesion(tester, auth);

      expect(find.textContaining('Hola'), findsNothing);
      expect(find.textContaining('Rol desconocido'), findsNothing);
      expect(find.text('No pudimos cargar tu perfil'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('reintentar vuelve a consultar y entra', (tester) async {
      final auth = FakeAuthRepository()..errorPerfil = StateError('sin red');
      await abrirConSesion(tester, auth);
      expect(auth.consultasPerfil, 1);

      auth.errorPerfil = null;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(auth.consultasPerfil, 2);
      expect(find.textContaining('Hola, Nombre uid1'), findsOneWidget);
    });

    testWidgets('con error de perfil se puede cerrar sesión', (tester) async {
      final auth = FakeAuthRepository()..errorPerfil = StateError('sin red');
      await abrirConSesion(tester, auth);

      await tester.tap(find.byTooltip('Cerrar sesión'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('cambiar de cuenta consulta el perfil de la nueva', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      await abrirConSesion(tester, auth);
      expect(find.textContaining('Hola, Nombre uid1'), findsOneWidget);

      auth.sesion.add('uid2');
      await tester.pumpAndSettle();

      expect(find.textContaining('Hola, Nombre uid1'), findsNothing);
      expect(find.textContaining('Hola, Nombre uid2'), findsOneWidget);
    });
  });

  group('login', () {
    testWidgets('campos vacíos no llaman a Firebase', (tester) async {
      final auth = FakeAuthRepository();
      await abrirApp(tester, auth);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Ingresar'));
      await tester.pump();

      expect(auth.intentosIngreso, 0);
      expect(find.text('Escribe tu correo'), findsOneWidget);
    });

    testWidgets('muestra el mensaje de un error de autenticación', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..errorAlIngresar = const AuthException(
          'Correo o contraseña incorrectos.',
        );
      await abrirApp(tester, auth);
      await llenarLogin(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Ingresar'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('un error inesperado no muestra su texto técnico', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..errorAlIngresar = StateError('traza técnica');
      await abrirApp(tester, auth);
      await llenarLogin(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Ingresar'));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('traza técnica'), findsNothing);
      expect(find.textContaining('No se pudo iniciar sesión'), findsOneWidget);
    });

    testWidgets('el botón se bloquea y no permite envíos repetidos', (
      tester,
    ) async {
      final auth = FakeAuthRepository()..espera = Completer<void>();
      await abrirApp(tester, auth);
      await llenarLogin(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Ingresar'));
      await tester.pump();

      final boton = find.widgetWithText(ElevatedButton, 'Ingresando...');
      expect(tester.widget<ElevatedButton>(boton).onPressed, isNull);
      await tester.tap(boton, warnIfMissed: false);
      await tester.pump();
      expect(auth.intentosIngreso, 1);

      auth.espera!.complete();
      await tester.pumpAndSettle();
      expect(find.textContaining('Hola, Nombre uid1'), findsOneWidget);
    });
  });

  group('registro', () {
    Future<void> abrirRegistro(
      WidgetTester tester,
      FakeAuthRepository auth,
    ) async {
      await abrirApp(tester, auth);
      await tester.tap(find.text('Crear una cuenta'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'),
        'Ana',
      );
      await llenarLogin(tester);
    }

    testWidgets('al crear la cuenta se cierra y queda en el inicio', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      await abrirRegistro(tester, auth);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Crear cuenta'));
      await tester.pumpAndSettle();

      expect(auth.intentosRegistro, 1);
      expect(find.textContaining('Hola, Nombre uid1'), findsOneWidget);
    });

    testWidgets('un correo existente muestra el mensaje y sigue en registro', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..errorAlRegistrar = const AuthException(
          'Ya existe una cuenta con este correo.',
        );
      await abrirRegistro(tester, auth);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Crear cuenta'));
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Ya existe una cuenta con este correo.'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(ElevatedButton, 'Crear cuenta'),
        findsOneWidget,
      );
    });
  });

  group('bandeja del operador', () {
    Pedido pedido(String id, EstadoPedido estado, {String? repartidorUid}) =>
        Pedido(
          id: id,
          clienteUid: 'cliente-1',
          lineas: const [],
          direccion: 'Calle $id',
          estado: estado,
          repartidorUid: repartidorUid,
          createdAt: DateTime(2026, 11, 8),
          updatedAt: DateTime(2026, 11, 8),
          estadoSync: EstadoSync.sincronizado,
        );

    Future<FakePedidoRepository> abrir(
      WidgetTester tester,
      List<Pedido> bandeja,
    ) async {
      final repo = FakePedidoRepository()
        ..bandeja = bandeja
        ..repartidores = const [
          Perfil(
            uid: 'r1',
            nombre: 'Rita',
            email: 'r@b.co',
            rol: Rol.repartidor,
          ),
        ];
      await tester.pumpWidget(
        MaterialApp(
          home: InicioOperador(
            perfil: const Perfil(
              uid: 'op',
              nombre: 'Op',
              email: 'o@b.co',
              rol: Rol.operador,
            ),
            authRepository: FakeAuthRepository(),
            pedidoRepository: repo,
          ),
        ),
      );
      await tester.pumpAndSettle();
      return repo;
    }

    testWidgets('cada estado muestra su acción', (tester) async {
      tester.view.physicalSize = const Size(400, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await abrir(tester, [
        pedido('1', EstadoPedido.creado),
        pedido('2', EstadoPedido.confirmado),
        pedido('3', EstadoPedido.preparando),
        pedido('4', EstadoPedido.listo),
        pedido('5', EstadoPedido.listo, repartidorUid: 'r1'),
      ]);

      expect(find.text('Confirmar'), findsOneWidget);
      expect(find.text('Rechazar'), findsOneWidget);
      expect(find.text('Empezar preparación'), findsOneWidget);
      expect(find.text('Marcar listo'), findsOneWidget);
      expect(find.text('Asignar repartidor'), findsOneWidget);
      expect(find.text('Cambiar repartidor'), findsOneWidget);
      expect(find.text('Repartidor: Rita'), findsOneWidget);
    });

    testWidgets('preparar y marcar listo llaman al repositorio', (
      tester,
    ) async {
      final repo = await abrir(tester, [
        pedido('2', EstadoPedido.confirmado),
        pedido('3', EstadoPedido.preparando),
      ]);

      await tester.tap(find.text('Empezar preparación'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marcar listo'));
      await tester.pumpAndSettle();

      expect(repo.llamadas, ['preparar 2', 'listo 3']);
    });

    testWidgets('asignar elige un repartidor de la lista', (tester) async {
      final repo = await abrir(tester, [pedido('4', EstadoPedido.listo)]);

      await tester.tap(find.text('Asignar repartidor'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rita'));
      await tester.pumpAndSettle();

      expect(repo.llamadas, ['asignar 4 r1']);
      expect(find.text('Pedido asignado a Rita.'), findsOneWidget);
    });
  });
}
