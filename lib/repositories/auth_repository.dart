import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;

import '../core/errores.dart';
import '../models/perfil.dart';
import '../remote/auth_remote_data_source.dart';
import '../remote/perfil_remote_data_source.dart';

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

  /// Si la cuenta no tiene perfil, lo crea con rol cliente.
  /// Lanza `FormatException` si el rol es desconocido, y otros errores si no
  /// se pudo consultar. Nunca devuelve un rol que no esté guardado.
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
  final AuthRemoteDataSource auth;
  final PerfilRemoteDataSource perfiles;

  /// Firestore puede esperar indefinidamente sin conexión.
  final Duration tiempoLimite;

  FirebaseAuthRepository({
    required this.auth,
    required this.perfiles,
    this.tiempoLimite = const Duration(seconds: 10),
  });

  @override
  Stream<String?> observarSesion() => auth.observarUid();

  @override
  Future<void> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final String uid;
    try {
      uid = await auth.crearCuenta(email, password);
    } on FirebaseAuthException catch (error) {
      throw AuthException(mensajeDeErrorAuth(error.code));
    }

    try {
      await perfiles
          .guardar(
            Perfil(uid: uid, nombre: nombre, email: email, rol: Rol.cliente),
          )
          .timeout(tiempoLimite);
    } catch (_) {
      // La cuenta ya existe: reportar error haría que el usuario intente
      // registrarse de nuevo. `obtenerPerfil` crea el perfil que faltó.
    }
  }

  @override
  Future<void> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      await auth.iniciarSesion(email, password);
    } on FirebaseAuthException catch (error) {
      throw AuthException(mensajeDeErrorAuth(error.code));
    }
  }

  @override
  Future<void> cerrarSesion() => auth.cerrarSesion();

  @override
  Future<Perfil> obtenerPerfil(String uid) async {
    final guardado = await perfiles.obtener(uid).timeout(tiempoLimite);
    if (guardado != null) return Perfil.fromFirestore(uid, guardado);

    final creado = await perfiles
        .crearSiNoExiste(_perfilBasico(uid))
        .timeout(tiempoLimite);
    return Perfil.fromFirestore(uid, creado);
  }

  /// Perfil de una cuenta que quedó sin él: siempre con rol cliente.
  Perfil _perfilBasico(String uid) {
    final email = auth.emailActual ?? '';
    return Perfil(
      uid: uid,
      nombre: email.split('@').first,
      email: email,
      rol: Rol.cliente,
    );
  }
}
