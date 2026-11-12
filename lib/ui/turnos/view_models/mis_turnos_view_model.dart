import 'dart:async';
import 'package:clinica_vitalis/data/repositories/turno_repository.dart';
import 'package:clinica_vitalis/data/services/notificaciones_service.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/evento_de_app.dart';
import '../../../data/services/bus_de_eventos.dart';

/// Estado y lógica de la pantalla Mis turnos.
class MisTurnosViewModel extends ChangeNotifier {
  MisTurnosViewModel({
    required TurnoRepository repositorio,
    required NotificacionesService notificacionesService,
    required this.pacienteUid,
  })  : _repositorio = repositorio,
        _notificacionesService = notificacionesService {
    // Nos suscribimos al Stream global de eventos
    _suscripcionEventos = busDeEventos.stream.listen(_manejarEventosApp);
  }

  final TurnoRepository _repositorio;
  final NotificacionesService _notificacionesService;
  final String pacienteUid;

  late final StreamSubscription<EventoDeApp> _suscripcionEventos;

  EstadoCarga _estado = EstadoCarga.inicial;
  List<Turno> _turnos = [];
  String? _error;
  int? _turnoCancelando;

  EstadoCarga get estado => _estado;
  List<Turno> get turnos => List.unmodifiable(_turnos);
  String? get error => _error;
  bool get estaCancelando => _turnoCancelando != null;

  /// Método que reacciona cada vez que el Bus de Eventos transmite algo
  void _manejarEventosApp(EventoDeApp evento) {
    if (evento is TurnoConfirmadoEvento) {
      debugPrint('MisTurnosViewModel escuchó: ¡Nuevo turno confirmado! Recargando...');
      cargar(pacienteUid);
    }
  }

  @override
  void dispose() {
    // Cerramos la suscripción del Stream para evitar fugas de memoria
    _suscripcionEventos.cancel();
    super.dispose();
  }

  /// Carga los turnos confirmados y futuros del paciente.
  Future<void> cargar(String pacienteUid) async {
    _estado = EstadoCarga.cargando;
    _error = null;
    notifyListeners();

    try {
      _turnos = await _repositorio.obtenerTurnos(pacienteUid);
      _estado = EstadoCarga.exito;
    } catch (_) {
      _turnos = [];
      _estado = EstadoCarga.error;
      _error = 'No se pudieron cargar tus turnos.';
    }

    notifyListeners();
  }

  /// Cancela un turno y actualiza la lista.
  Future<bool> cancelar(Turno turno) async {
    if (turno.id == null) return false;

    _turnoCancelando = turno.id;
    _error = null;
    notifyListeners();

    try {
      await _repositorio.cancelarTurno(turno.id!);
      await _notificacionesService.cancelarRecordatorio(turno.id!);

      _turnos =
          _turnos.where((turnoActual) => turnoActual.id != turno.id).toList();

      return true;
    } catch (_) {
      _error = 'No se pudo cancelar el turno. Probá de nuevo.';
      return false;
    } finally {
      _turnoCancelando = null;
      notifyListeners();
    }
  }
}