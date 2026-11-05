import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth auth;

  AuthRemoteDataSource(this.auth);

  /// Firebase guarda la sesión: al reabrir la app emite el uid sin pedir login.
  Stream<String?> observarUid() =>
      auth.authStateChanges().map((usuario) => usuario?.uid);

  Future<void> crearCuenta(String email, String password) =>
      auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> iniciarSesion(String email, String password) =>
      auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> cerrarSesion() => auth.signOut();
}
