import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/perfil_service.dart';

class PerfilRepository {
  final PerfilService _perfilService;

  PerfilRepository({PerfilService? perfilService})
      : _perfilService = perfilService ?? PerfilService();

  Future<Map<String, dynamic>?> cargarPerfilUsuario(String uid) async {
    return await _perfilService.obtenerPerfil(uid);
  }

  Future<void> actualizarDatosPerfil(String uid, {String? nombre, String? telefono, String? obraSocial}) async {
    final Map<String, dynamic> datos = {};

    if (nombre != null) datos['nombre'] = nombre;
    if (telefono != null) datos['telefono'] = telefono;
    if (obraSocial != null) datos['obraSocial'] = obraSocial;
    datos['actualizadoEn'] = FieldValue.serverTimestamp();

    await _perfilService.guardarPerfil(uid, datos);
  }
}