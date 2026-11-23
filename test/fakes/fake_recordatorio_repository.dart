import 'package:clinica_vitalis/data/repositories/recordatorio_repository.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';

/// [RecordatorioRepository] en memoria para los tests.
class FakeRecordatorioRepository implements RecordatorioRepository {
  final List<Turno> programados = [];
  final List<int> cancelados = [];

  @override
  Future<void> programarRecordatorio(Turno turno) async =>
      programados.add(turno);

  @override
  Future<void> cancelarRecordatorio(int idTurno) async =>
      cancelados.add(idTurno);
}
