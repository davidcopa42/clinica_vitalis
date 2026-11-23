import '../../domain/models/paciente.dart';
import '../services/perfil_service.dart';
import 'perfil_repository.dart';

/// Implementacion de [PerfilRepository] sobre [PerfilService] (Firestore).
///
/// Guarda en memoria el ultimo perfil leido o guardado.
class PerfilRepositoryFirestore implements PerfilRepository {
  PerfilRepositoryFirestore({required PerfilService perfilService})
      : _perfilService = perfilService;

  final PerfilService _perfilService;
  Paciente? _pacienteEnCache;

  @override
  Future<Paciente?> obtenerPerfil(
    String uid, {
    bool forzarRecarga = false,
  }) async {
    final cache = _pacienteEnCache;
    if (!forzarRecarga && cache != null && cache.uid == uid) return cache;

    final mapa = await _perfilService.obtenerPerfil(uid);
    if (mapa == null || mapa.isEmpty) {
      _pacienteEnCache = null;
      return null;
    }

    final paciente = Paciente.fromMap({...mapa, 'uid': uid});
    _pacienteEnCache = paciente;
    return paciente;
  }

  @override
  Future<void> guardarPerfil(Paciente paciente) async {
    await _perfilService.guardarPerfil(paciente.uid, paciente.toMap());
    _pacienteEnCache = paciente;
  }
}
