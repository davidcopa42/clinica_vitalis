import '../../domain/models/paciente.dart';

/// Contrato para leer y guardar el perfil del paciente.
abstract class PerfilRepository {
  /// Devuelve el perfil del paciente [uid], o null si no existe.
  ///
  /// Usa la copia en memoria salvo que [forzarRecarga] sea true.
  Future<Paciente?> obtenerPerfil(String uid, {bool forzarRecarga = false});

  /// Guarda el perfil completo del [paciente].
  Future<void> guardarPerfil(Paciente paciente);
}
