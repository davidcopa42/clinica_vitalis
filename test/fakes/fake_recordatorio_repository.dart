import 'package:clinica_vitalis/data/repositories/recordatorio_repository.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';

/// Repositorio de recordatorios falso que registra las llamadas.
class FakeRecordatorioRepository implements RecordatorioRepository {
  final List<Turno> turnosProgramados = [];
  final List<int> recordatoriosCancelados = [];
  int permisosPedidos = 0;

  /// Respuesta del usuario a [pedirPermiso].
  bool permisoOtorgado = true;

  /// Si no es null, el metodo correspondiente lanza este error.
  Object? errorAlProgramar;
  Object? errorAlCancelar;
  Object? errorAlPedirPermiso;

  @override
  Future<void> programarRecordatorio(Turno turno) async {
    turnosProgramados.add(turno);
    if (errorAlProgramar != null) throw errorAlProgramar!;
  }

  @override
  Future<void> cancelarRecordatorio(int turnoId) async {
    recordatoriosCancelados.add(turnoId);
    if (errorAlCancelar != null) throw errorAlCancelar!;
  }

  @override
  Future<bool> pedirPermiso() async {
    permisosPedidos++;
    if (errorAlPedirPermiso != null) throw errorAlPedirPermiso!;
    return permisoOtorgado;
  }
}
