import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedidos_entregas/core/errores.dart';
import 'package:pedidos_entregas/main.dart';
import 'package:pedidos_entregas/models/perfil.dart';
import 'package:pedidos_entregas/repositories/auth_repository.dart';
import 'package:pedidos_entregas/screens/auth/login_screen.dart';

class FakeAuthRepository implements AuthRepository {
  final sesion = StreamController<String?>.broadcast();
  Object? errorAlIngresar;
  Object? errorAlRegistrar;
  Completer<void>? espera;
  int intentosIngreso = 0;
  int intentosRegistro = 0;
  int cierresSesion = 0;

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
  Future<Perfil> obtenerPerfil(String uid) => throw UnimplementedError();
}

Future<void> abrirApp(WidgetTester tester, FakeAuthRepository auth) async {
  await tester.pumpWidget(PedidosEntregasApp(authRepository: auth));
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
      await tester.pumpWidget(PedidosEntregasApp(authRepository: auth));
      auth.sesion.add('uid1');
      await tester.pump();
      await tester.pump();
      expect(find.text('Sesión iniciada'), findsOneWidget);

      await tester.tap(find.byTooltip('Cerrar sesión'));
      await tester.pump();
      await tester.pump();
      expect(auth.cierresSesion, 1);
      expect(find.byType(LoginScreen), findsOneWidget);
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
      await tester.pump();
      await tester.pump();
      expect(find.text('Sesión iniciada'), findsOneWidget);
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
      expect(find.text('Sesión iniciada'), findsOneWidget);
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
}
