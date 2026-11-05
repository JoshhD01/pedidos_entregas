import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth auth;

  AuthRemoteDataSource(this.auth);

  /// Firebase guarda la sesión: al reabrir la app emite el uid sin pedir login.
  Stream<String?> observarUid() =>
      auth.authStateChanges().map((usuario) => usuario?.uid);

  String? get emailActual => auth.currentUser?.email;

  /// Devuelve el uid de la cuenta creada.
  Future<String> crearCuenta(String email, String password) async {
    final credencial = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credencial.user!.uid;
  }

  Future<void> iniciarSesion(String email, String password) =>
      auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> cerrarSesion() => auth.signOut();
}
