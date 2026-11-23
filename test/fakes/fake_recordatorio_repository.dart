import 'package:clinica_vitalis/data/repositories/recordatorio_repository.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';

/// Repositorio de recordatorios falso que registra las llamadas.
class FakeRecordatorioRepository implements RecordatorioRepository {
  final List<Turno> turnosProgramados = [];
  final List<int> recordatoriosCancelados = [];

  /// Si no es null, el metodo correspondiente lanza este error.
  Object? errorAlProgramar;
  Object? errorAlCancelar;

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
}
