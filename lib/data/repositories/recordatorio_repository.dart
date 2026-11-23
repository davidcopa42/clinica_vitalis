import '../../domain/models/turno.dart';

/// Contrato para programar y cancelar los recordatorios de turnos.
abstract class RecordatorioRepository {
  /// Programa el aviso previo al turno, si corresponde.
  Future<void> programarRecordatorio(Turno turno);

  /// Cancela el aviso del turno con ese id.
  Future<void> cancelarRecordatorio(int turnoId);
}
