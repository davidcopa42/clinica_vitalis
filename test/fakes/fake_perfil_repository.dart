import 'package:clinica_vitalis/data/repositories/perfil_repository.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';

/// [PerfilRepository] en memoria para los tests.
class FakePerfilRepository implements PerfilRepository {
  FakePerfilRepository({this.paciente});

  Paciente? paciente;

  @override
  Future<Paciente?> obtenerPerfil(
    String uid, {
    bool forzarRecarga = false,
  }) async =>
      paciente;

  @override
  Future<void> guardarPerfil(Paciente paciente) async =>
      this.paciente = paciente;
}
