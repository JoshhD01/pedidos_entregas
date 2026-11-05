import '../models/perfil.dart';

/// Sesión y perfil del usuario. Se implementa en T5 y T6.
abstract class AuthRepository {
  /// Emite el uid de la sesión activa, o null si no hay sesión.
  Stream<String?> observarSesion();

  /// Crea la cuenta y su perfil con rol cliente. El usuario no elige rol.
  Future<void> registrar({
    required String nombre,
    required String email,
    required String password,
  });

  Future<void> iniciarSesion({required String email, required String password});

  Future<void> cerrarSesion();

  /// Lanza `FormatException` si el rol es desconocido.
  Future<Perfil> obtenerPerfil(String uid);
}
