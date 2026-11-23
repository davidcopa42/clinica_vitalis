import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/recordatorio_repository.dart';
import '../../../data/repositories/turno_repository.dart';
import '../../../domain/models/evento_de_app.dart';
import '../../../domain/models/turno.dart';
import '../../core/bus_de_eventos.dart';
import '../../core/estado_carga.dart';

/// Estado y comandos de la pantalla Mis turnos.
class MisTurnosViewModel extends ChangeNotifier {
  MisTurnosViewModel({
    required TurnoRepository turnoRepository,
    required RecordatorioRepository recordatorioRepository,
    required AuthRepository authRepository,
    required BusDeEventos busDeEventos,
  })  : _turnoRepository = turnoRepository,
        _recordatorioRepository = recordatorioRepository,
        _authRepository = authRepository,
        _busDeEventos = busDeEventos {
    _suscripcionEventos = busDeEventos.eventos.listen(_reaccionarAEvento);
  }

  final TurnoRepository _turnoRepository;
  final RecordatorioRepository _recordatorioRepository;
  final AuthRepository _authRepository;
  final BusDeEventos _busDeEventos;
  late final StreamSubscription<EventoDeApp> _suscripcionEventos;

  EstadoCarga _estado = EstadoCarga.inicial;
  List<Turno> _turnos = [];
  String? _error;
  int? _idTurnoCancelando;

  EstadoCarga get estado => _estado;
  List<Turno> get turnos => List.unmodifiable(_turnos);
  bool get tieneTurnos => _turnos.isNotEmpty;
  String? get error => _error;

  /// Indica si [turno] es el que se esta cancelando ahora.
  bool estaCancelandoTurno(Turno turno) =>
      turno.id != null && turno.id == _idTurnoCancelando;

  /// Carga los turnos confirmados y futuros del paciente.
  Future<void> cargar() async {
    final uid = _authRepository.uidActual;
    if (uid == null) return;

    _estado = EstadoCarga.cargando;
    _error = null;
    notifyListeners();

    try {
      _turnos = await _turnoRepository.obtenerTurnos(uid);
      _estado = EstadoCarga.exito;
    } catch (_) {
      _turnos = [];
      _estado = EstadoCarga.error;
      _error = 'No se pudieron cargar tus turnos.';
    }
    notifyListeners();
  }

  /// Cancela [turno], quita su recordatorio y lo saca de la lista.
  ///
  /// Devuelve true si se pudo cancelar.
  Future<bool> cancelar(Turno turno) async {
    final id = turno.id;
    if (id == null) return false;

    _idTurnoCancelando = id;
    _error = null;
    notifyListeners();

    try {
      await _turnoRepository.cancelarTurno(id);
      await _recordatorioRepository.cancelarRecordatorio(id);
      _turnos = _turnos.where((actual) => actual.id != id).toList();
      _busDeEventos.publicar(TurnoCanceladoEvento(id));
      return true;
    } catch (_) {
      _error = 'No se pudo cancelar el turno. Probá de nuevo.';
      return false;
    } finally {
      _idTurnoCancelando = null;
      notifyListeners();
    }
  }

  void _reaccionarAEvento(EventoDeApp evento) {
    if (evento is TurnoConfirmadoEvento) cargar();
  }

  @override
  void dispose() {
    _suscripcionEventos.cancel();
    super.dispose();
  }
}
