import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/recordatorio_repository.dart';
import '../../../data/services/bus_de_eventos.dart';
import '../../../domain/models/evento_de_app.dart';
import '../../../domain/models/paciente.dart';

/// Estado y lógica de la pantalla Inicio.
///
/// Escucha el bus de eventos y deja un aviso pendiente para que la
/// pantalla lo muestre cuando se confirma un turno. También avisa cuando
/// hay que abrir Mis turnos porque el paciente tocó un recordatorio.
class InicioViewModel extends ChangeNotifier {
  InicioViewModel({
    required BusDeEventos busDeEventos,
    required AuthRepository authRepository,
    required RecordatorioRepository recordatorioRepository,
    required Paciente paciente,
  })  : _authRepo = authRepository,
        _recordatorioRepository = recordatorioRepository,
        _paciente = paciente {
    _suscripcionEventos = busDeEventos.stream.listen(_manejarEvento);
    _suscripcionRecordatorios = recordatorioRepository.recordatoriosTocados
        .listen((_) => _revisarRecordatorioTocado());
    _revisarRecordatorioTocado();
  }

  final AuthRepository _authRepo;
  final RecordatorioRepository _recordatorioRepository;
  final Paciente _paciente;
  late final StreamSubscription<EventoDeApp> _suscripcionEventos;
  late final StreamSubscription<void> _suscripcionRecordatorios;

  String? _avisoPendiente;
  bool _debeAbrirMisTurnos = false;
  bool _descartado = false;

  /// Si la pantalla tiene que abrir Mis turnos porque el paciente tocó
  /// un recordatorio.
  bool get debeAbrirMisTurnos => _debeAbrirMisTurnos;

  /// Mensaje que la pantalla tiene que mostrar, o null si no hay ninguno.
  String? get avisoPendiente => _avisoPendiente;

  /// Nombre para el saludo; 'Paciente' si todavía no tiene nombre.
  String get nombreUsuario =>
      _paciente.nombre.isNotEmpty ? _paciente.nombre : 'Paciente';

  /// Saludo de la pantalla, por ejemplo "Hola, Ana".
  String get saludo => 'Hola, $nombreUsuario';

  /// Foto de la cuenta; si no tiene, la del perfil del paciente.
  String? get fotoUrl => _authRepo.usuarioActual?.fotoUrl ?? _paciente.fotoUrl;

  /// Foto para el avatar, o null si no hay ninguna que mostrar.
  String? get fotoParaMostrar {
    final foto = fotoUrl;
    return (foto == null || foto.isEmpty) ? null : foto;
  }

  /// El perfil se puede abrir solo si el paciente está identificado.
  bool get puedeAbrirPerfil => _paciente.uid.isNotEmpty;

  /// La pantalla lo llama después de mostrar el aviso.
  void descartarAviso() {
    _avisoPendiente = null;
  }

  /// La pantalla lo llama después de abrir Mis turnos.
  void descartarAperturaMisTurnos() {
    _debeAbrirMisTurnos = false;
  }

  Future<void> _revisarRecordatorioTocado() async {
    final bool tocado;
    try {
      tocado = await _recordatorioRepository.consumirRecordatorioTocado();
    } catch (_) {
      return;
    }
    if (!tocado || _descartado) return;

    _debeAbrirMisTurnos = true;
    notifyListeners();
  }

  void _manejarEvento(EventoDeApp evento) {
    if (evento is TurnoConfirmadoEvento) {
      _avisoPendiente = '¡Éxito! Turno de ${evento.especialidad} registrado.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _descartado = true;
    _suscripcionEventos.cancel();
    _suscripcionRecordatorios.cancel();
    super.dispose();
  }
}
