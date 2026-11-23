import '../../domain/models/paciente.dart';

/// Contrato para leer y guardar el perfil del paciente.
abstract class PerfilRepository {
  /// Datos crudos del perfil, o null si no existe.
  Future<Map<String, dynamic>?> cargarPerfilUsuario(String uid);

  /// Perfil del paciente como [Paciente], o null si no existe.
  Future<Paciente?> obtenerPerfil(String uid);

  /// Guarda (combinando con lo existente) los datos del perfil.
  Future<void> guardarPerfil(String uid, Map<String, dynamic> datosPerfil);

}
