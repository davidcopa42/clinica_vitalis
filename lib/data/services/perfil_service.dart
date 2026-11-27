import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilService {
  static const _coleccionPerfiles = 'perfiles';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> obtenerPerfil(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_coleccionPerfiles).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (error) {
      throw Exception('Error al obtener el perfil: $error');
    }
  }

  Future<void> guardarPerfil(
      String uid, Map<String, dynamic> datosPerfil) async {
    try {
      await _firestore.collection(_coleccionPerfiles).doc(uid).set(
            datosPerfil,
            SetOptions(merge: true),
          );
    } catch (error) {
      throw Exception('Error al guardar el perfil: $error');
    }
  }
}
