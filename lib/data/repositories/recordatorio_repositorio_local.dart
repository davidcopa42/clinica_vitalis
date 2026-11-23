import '../../domain/models/turno.dart';
import '../services/notificaciones_service.dart';
import 'recordatorio_repository.dart';

/// Implementación de [RecordatorioRepository] con notificaciones locales
/// mediante [NotificacionesService].
class RecordatorioRepositorioLocal implements RecordatorioRepository {
  RecordatorioRepositorioLocal({
    required NotificacionesService notificacionesService,
  }) : _notificacionesService = notificacionesService;

  final NotificacionesService _notificacionesService;

  @override
  Future<void> programarRecordatorio(Turno turno) async {
    await _notificacionesService.programarRecordatorio(turno);
  }

  @override
  Future<void> cancelarRecordatorio(int turnoId) async {
    await _notificacionesService.cancelarRecordatorio(turnoId);
  }
}
