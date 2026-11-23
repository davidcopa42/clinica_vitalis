import '../../domain/models/turno.dart';
import '../services/notificaciones_service.dart';
import 'recordatorio_repository.dart';

/// Implementacion de [RecordatorioRepository] con notificaciones locales.
class RecordatorioRepositoryLocal implements RecordatorioRepository {
  RecordatorioRepositoryLocal({
    required NotificacionesService notificacionesService,
  }) : _notificaciones = notificacionesService;

  /// Cuanto antes del turno se avisa al paciente.
  static const anticipacion = Duration(hours: 24);

  final NotificacionesService _notificaciones;

  /// Solo programa turnos guardados, confirmados y cuyo aviso sea futuro.
  @override
  Future<void> programarRecordatorio(Turno turno) async {
    final id = turno.id;
    if (id == null || turno.estado != EstadoTurno.confirmado) return;

    final fechaAviso = turno.fechaHora.subtract(anticipacion);
    if (!fechaAviso.isAfter(DateTime.now())) return;

    await _notificaciones.programar(
      id: id,
      titulo: 'Recordatorio de turno',
      cuerpo: 'Mañana tenés turno con ${turno.profesional} '
          'a las ${turno.horario}.',
      fecha: fechaAviso,
    );
  }

  @override
  Future<void> cancelarRecordatorio(int idTurno) =>
      _notificaciones.cancelar(idTurno);
}
