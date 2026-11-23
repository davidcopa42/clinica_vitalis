import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/paciente.dart';
import '../services/perfil_service.dart';
import 'perfil_repository.dart';

/// Implementación de [PerfilRepository] que guarda el perfil en Firestore
/// mediante [PerfilService].
class PerfilRepositorioFirestore implements PerfilRepository {
  final PerfilService _perfilService;

  PerfilRepositorioFirestore({required PerfilService perfilService})
      : _perfilService = perfilService;

  @override
  Future<Map<String, dynamic>?> cargarPerfilUsuario(String uid) async {
    return await _perfilService.obtenerPerfil(uid);
  }

  @override
  Future<Paciente?> obtenerPerfil(String uid) async {
    final mapa = await _perfilService.obtenerPerfil(uid);
    if (mapa == null) return null;
    final datosConUid = Map<String, Object?>.from(mapa);
    final uidGuardado = datosConUid['uid'] as String?;
    if (uidGuardado == null || uidGuardado.isEmpty) {
      datosConUid['uid'] = uid;
    }
    return Paciente.fromMap(datosConUid);
  }

  @override
  Future<void> guardarPerfil(
      String uid, Map<String, dynamic> datosPerfil) async {
    await _perfilService.guardarPerfil(uid, datosPerfil);
  }

  @override
  Future<void> actualizarDatosPerfil(String uid,
      {String? nombre, String? telefono, String? obraSocial}) async {
    final Map<String, dynamic> datos = {};

    if (nombre != null) datos['nombre'] = nombre;
    if (telefono != null) datos['telefono'] = telefono;
    if (obraSocial != null) datos['obraSocial'] = obraSocial;
    datos['actualizadoEn'] = FieldValue.serverTimestamp();

    await _perfilService.guardarPerfil(uid, datos);
  }
}
