import 'dart:async';

import '../../domain/models/turno.dart';
import '../services/notificaciones_service.dart';
import 'recordatorio_repository.dart';

/// Implementación de [RecordatorioRepository] con notificaciones locales
/// mediante [NotificacionesService].
///
/// Recuerda en memoria si hay un recordatorio tocado sin atender, porque
/// se puede tocar antes de que haya una pantalla lista para abrirlo.
class RecordatorioRepositorioLocal implements RecordatorioRepository {
  RecordatorioRepositorioLocal({
    required NotificacionesService notificacionesService,
  }) : _notificacionesService = notificacionesService {
    _notificacionesService.toques
        .where((payload) => payload == NotificacionesService.payloadMisTurnos)
        .listen((_) {
      _hayRecordatorioTocado = true;
      _recordatoriosTocados.add(null);
    });
  }

  final NotificacionesService _notificacionesService;
  final StreamController<void> _recordatoriosTocados =
      StreamController<void>.broadcast();

  bool _hayRecordatorioTocado = false;
  bool _lanzamientoRevisado = false;

  @override
  Future<void> programarRecordatorio(Turno turno) async {
    await _notificacionesService.programarRecordatorio(turno);
  }

  @override
  Future<void> cancelarRecordatorio(int turnoId) async {
    await _notificacionesService.cancelarRecordatorio(turnoId);
  }

  @override
  Future<bool> pedirPermiso() => _notificacionesService.pedirPermiso();

  @override
  Stream<void> get recordatoriosTocados => _recordatoriosTocados.stream;

  @override
  Future<bool> consumirRecordatorioTocado() async {
    if (!_lanzamientoRevisado) {
      _lanzamientoRevisado = true;
      final payload =
          await _notificacionesService.obtenerPayloadDeLanzamiento();
      if (payload == NotificacionesService.payloadMisTurnos) {
        _hayRecordatorioTocado = true;
      }
    }

    final hayRecordatorioTocado = _hayRecordatorioTocado;
    _hayRecordatorioTocado = false;
    return hayRecordatorioTocado;
  }
}
