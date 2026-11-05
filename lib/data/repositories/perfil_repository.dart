import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/paciente.dart';
import '../services/perfil_service.dart';

class PerfilRepository {
  final PerfilService _perfilService;

  PerfilRepository({PerfilService? perfilService})
      : _perfilService = perfilService ?? PerfilService();

  Future<Map<String, dynamic>?> cargarPerfilUsuario(String uid) async {
    return await _perfilService.obtenerPerfil(uid);
  }

  Future<Paciente?> obtenerPerfil(String uid) async {
    final mapa = await _perfilService.obtenerPerfil(uid);
    if (mapa == null) return null;
    final datosConUid = Map<String, Object?>.from(mapa);
    if (!datosConUid.containsKey('uid') ||
        datosConUid['uid'] == null ||
        (datosConUid['uid'] as String).isEmpty) {
      datosConUid['uid'] = uid;
    }
    return Paciente.fromMap(datosConUid);
  }

  Future<void> guardarPerfil(
      String uid, Map<String, dynamic> datosPerfil) async {
    await _perfilService.guardarPerfil(uid, datosPerfil);
  }

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
