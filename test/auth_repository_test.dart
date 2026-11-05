import 'package:flutter_test/flutter_test.dart';
import 'package:pedidos_entregas/models/perfil.dart';
import 'package:pedidos_entregas/remote/auth_remote_data_source.dart';
import 'package:pedidos_entregas/remote/perfil_remote_data_source.dart';
import 'package:pedidos_entregas/repositories/auth_repository.dart';

class FakeAuthRemote implements AuthRemoteDataSource {
  @override
  String? emailActual = 'ana.perez@prueba.com';

  @override
  Future<String> crearCuenta(String email, String password) async => 'uid1';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePerfilRemote implements PerfilRemoteDataSource {
  final documentos = <String, Map<String, dynamic>>{};
  bool fallaGuardar = false;
  bool fallaObtener = false;
  bool nuncaResponde = false;
  Perfil? creadoSiNoExiste;

  @override
  Future<Map<String, dynamic>?> obtener(String uid) async {
    if (nuncaResponde) await Future<void>.delayed(const Duration(hours: 1));
    if (fallaObtener) throw StateError('sin red');
    return documentos[uid];
  }

  @override
  Future<void> guardar(Perfil perfil) async {
    if (fallaGuardar) throw StateError('sin red');
    documentos[perfil.uid] = perfil.toFirestore();
  }

  @override
  Future<Map<String, dynamic>> crearSiNoExiste(Perfil perfil) async {
    creadoSiNoExiste = perfil;
    return documentos.putIfAbsent(perfil.uid, perfil.toFirestore);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakePerfilRemote perfiles;
  late FirebaseAuthRepository repositorio;

  setUp(() {
    perfiles = FakePerfilRemote();
    repositorio = FirebaseAuthRepository(
      auth: FakeAuthRemote(),
      perfiles: perfiles,
      tiempoLimite: const Duration(milliseconds: 20),
    );
  });

  Future<void> registrar() => repositorio.registrar(
    nombre: 'Ana',
    email: 'ana@prueba.com',
    password: 'secreta1',
  );

  group('registrar', () {
    test('crea el perfil con rol cliente', () async {
      await registrar();

      expect(perfiles.documentos['uid1'], {
        'nombre': 'Ana',
        'email': 'ana@prueba.com',
        'rol': 'cliente',
      });
    });

    test('si falla el perfil no reporta error: la cuenta ya existe', () async {
      perfiles.fallaGuardar = true;

      await expectLater(registrar(), completes);
      expect(perfiles.documentos, isEmpty);
    });
  });

  group('obtenerPerfil', () {
    test('devuelve el rol guardado', () async {
      perfiles.documentos['uid1'] = {
        'nombre': 'Op',
        'email': 'op@prueba.com',
        'rol': 'operador',
      };

      final perfil = await repositorio.obtenerPerfil('uid1');

      expect(perfil.rol, Rol.operador);
      expect(perfiles.creadoSiNoExiste, isNull);
    });

    test('una cuenta sin perfil queda con rol cliente', () async {
      final perfil = await repositorio.obtenerPerfil('uid1');

      expect(perfil.rol, Rol.cliente);
      expect(perfil.nombre, 'ana.perez');
      expect(perfil.email, 'ana.perez@prueba.com');
      expect(perfiles.documentos['uid1']!['rol'], 'cliente');
    });

    test('un rol desconocido es un error y no se reemplaza', () async {
      perfiles.documentos['uid1'] = {
        'nombre': 'X',
        'email': 'x@prueba.com',
        'rol': 'admin',
      };

      await expectLater(
        repositorio.obtenerPerfil('uid1'),
        throwsFormatException,
      );
      expect(perfiles.documentos['uid1']!['rol'], 'admin');
    });

    test('sin conexión es un error: no crea un perfil', () async {
      perfiles.fallaObtener = true;

      await expectLater(repositorio.obtenerPerfil('uid1'), throwsStateError);
      expect(perfiles.creadoSiNoExiste, isNull);
    });

    test('si Firestore no responde, vence el tiempo límite', () async {
      perfiles.nuncaResponde = true;

      await expectLater(
        repositorio.obtenerPerfil('uid1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
