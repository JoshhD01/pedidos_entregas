import 'package:cloud_firestore/cloud_firestore.dart';

class ProductoRemoteDataSource {
  final FirebaseFirestore firestore;

  ProductoRemoteDataSource(this.firestore);

  /// Null si el producto no existe.
  Future<Map<String, dynamic>?> obtener(String id) async {
    final documento = await firestore.collection('productos').doc(id).get();
    return documento.data();
  }
}
