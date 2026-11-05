import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;

import '../core/errores.dart';
import '../models/perfil.dart';
import '../remote/auth_remote_data_source.dart';

/// Sesión y perfil del usuario.
abstract class AuthRepository {
  /// Emite el uid de la sesión activa, o null si no hay sesión.
  Stream<String?> observarSesion();

  /// Crea la cuenta y su perfil con rol cliente. El usuario no elige rol.
  /// Lanza `AuthException` con un mensaje para el usuario.
  Future<void> registrar({
    required String nombre,
    required String email,
    required String password,
  });

  /// Lanza `AuthException` con un mensaje para el usuario.
  Future<void> iniciarSesion({required String email, required String password});

  Future<void> cerrarSesion();

  /// Lanza `FormatException` si el rol es desconocido.
  Future<Perfil> obtenerPerfil(String uid);
}

/// Traduce el código de Firebase a un mensaje sin detalles técnicos.
String mensajeDeErrorAuth(String codigo) {
  switch (codigo) {
    // Firebase no distingue si falló el correo o la contraseña, y es mejor así:
    // no revela qué correos tienen cuenta.
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return 'Correo o contraseña incorrectos.';
    case 'invalid-email':
      return 'El correo no es válido.';
    case 'weak-password':
      return 'Contraseña rechazada: usa al menos 6 caracteres.';
    case 'email-already-in-use':
      return 'Ya existe una cuenta con este correo.';
    case 'network-request-failed':
      return 'Sin conexión. Revisa tu internet e inténtalo de nuevo.';
    case 'too-many-requests':
      return 'Demasiados intentos. Espera un momento e inténtalo de nuevo.';
    case 'user-disabled':
      return 'Esta cuenta está deshabilitada.';
    default:
      return 'No se pudo completar la operación. Inténtalo de nuevo.';
  }
}

class FirebaseAuthRepository implements AuthRepository {
  final AuthRemoteDataSource remote;

  FirebaseAuthRepository(this.remote);

  @override
  Stream<String?> observarSesion() => remote.observarUid();

  @override
  Future<void> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      await remote.crearCuenta(email, password);
    } on FirebaseAuthException catch (error) {
      throw AuthException(mensajeDeErrorAuth(error.code));
    }
  }

  @override
  Future<void> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      await remote.iniciarSesion(email, password);
    } on FirebaseAuthException catch (error) {
      throw AuthException(mensajeDeErrorAuth(error.code));
    }
  }

  @override
  Future<void> cerrarSesion() => remote.cerrarSesion();

  @override
  Future<Perfil> obtenerPerfil(String uid) {
    throw UnimplementedError('Se implementa en T6');
  }
}
