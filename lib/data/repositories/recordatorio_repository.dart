import '../../domain/models/turno.dart';

/// Contrato para programar recordatorios de turnos.
abstract class RecordatorioRepository {
  /// Programa el recordatorio del [turno] si corresponde.
  Future<void> programarRecordatorio(Turno turno);

  /// Cancela el recordatorio del turno con ese [idTurno].
  Future<void> cancelarRecordatorio(int idTurno);
}
