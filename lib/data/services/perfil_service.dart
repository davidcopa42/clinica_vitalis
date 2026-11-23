import 'package:cloud_firestore/cloud_firestore.dart';

/// Acceso directo a la coleccion de perfiles en Firestore.
class PerfilService {
  PerfilService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  static const coleccionPerfiles = 'perfiles';

  final FirebaseFirestore _firestore;

  /// Devuelve el documento crudo del perfil, o null si no existe.
  Future<Map<String, dynamic>?> obtenerPerfil(String uid) async {
    final documento =
        await _firestore.collection(coleccionPerfiles).doc(uid).get();
    return documento.data();
  }

  /// Guarda los datos combinandolos con los que ya existan.
  Future<void> guardarPerfil(String uid, Map<String, dynamic> datos) async {
    await _firestore
        .collection(coleccionPerfiles)
        .doc(uid)
        .set(datos, SetOptions(merge: true));
  }
}
