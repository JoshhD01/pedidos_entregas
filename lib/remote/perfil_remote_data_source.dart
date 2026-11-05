import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/perfil.dart';

class PerfilRemoteDataSource {
  final FirebaseFirestore firestore;

  PerfilRemoteDataSource(this.firestore);

  DocumentReference<Map<String, dynamic>> _documento(String uid) =>
      firestore.collection('perfiles').doc(uid);

  /// Null si el perfil no existe.
  Future<Map<String, dynamic>?> obtener(String uid) async {
    final documento = await _documento(uid).get();
    return documento.data();
  }

  Future<void> guardar(Perfil perfil) =>
      _documento(perfil.uid).set(perfil.toFirestore());

  /// Crea el perfil solo si no existe, y devuelve el que quedó guardado.
  /// La transacción evita pisar un perfil creado por otra operación.
  Future<Map<String, dynamic>> crearSiNoExiste(Perfil perfil) {
    return firestore.runTransaction((transaccion) async {
      final referencia = _documento(perfil.uid);
      final actual = await transaccion.get(referencia);
      final datos = actual.data();
      if (datos != null) return datos;

      transaccion.set(referencia, perfil.toFirestore());
      return perfil.toFirestore();
    });
  }
}
