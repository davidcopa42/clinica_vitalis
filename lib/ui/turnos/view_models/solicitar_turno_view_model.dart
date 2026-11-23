import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/borrador_repository.dart';
import '../../../data/repositories/perfil_repository.dart';
import '../../../data/repositories/recordatorio_repository.dart';
import '../../../data/repositories/turno_no_disponible_exception.dart';
import '../../../data/repositories/turno_repository.dart';
import '../../../domain/models/borrador_turno.dart';
import '../../../domain/models/evento_de_app.dart';
import '../../../domain/models/paciente.dart';
import '../../../domain/models/profesional.dart';
import '../../../domain/models/turno.dart';
import '../../core/bus_de_eventos.dart';
import '../../core/estado_carga.dart';
import '../../core/formato.dart';

/// Estado y comandos de la pantalla Solicitar turno.
class SolicitarTurnoViewModel extends ChangeNotifier {
  SolicitarTurnoViewModel({
    required TurnoRepository turnoRepository,
    required BorradorRepository borradorRepository,
    required RecordatorioRepository recordatorioRepository,
    required AuthRepository authRepository,
    required PerfilRepository perfilRepository,
    required BusDeEventos busDeEventos,
  })  : _turnoRepository = turnoRepository,
        _borradorRepository = borradorRepository,
        _recordatorioRepository = recordatorioRepository,
        _authRepository = authRepository,
        _perfilRepository = perfilRepository,
        _busDeEventos = busDeEventos;

  /// Cuantos dias hacia adelante se puede reservar.
  static const diasMaximosAnticipacion = 90;

  final TurnoRepository _turnoRepository;
  final BorradorRepository _borradorRepository;
  final RecordatorioRepository _recordatorioRepository;
  final AuthRepository _authRepository;
  final PerfilRepository _perfilRepository;
  final BusDeEventos _busDeEventos;

  EstadoCarga _estado = EstadoCarga.inicial;
  Paciente? _paciente;
  List<Profesional> _profesionales = [];
  String? _especialidad;
  String? _profesional;
  DateTime? _fecha;
  String? _horario;
  List<String> _horariosDisponibles = [];
  bool _estaCargandoHorarios = false;
  bool _estaGuardando = false;
  String? _error;

  EstadoCarga get estado => _estado;
  Paciente? get paciente => _paciente;
  String? get especialidadSeleccionada => _especialidad;
  String? get profesionalSeleccionado => _profesional;
  DateTime? get fechaSeleccionada => _fecha;
  String? get horarioSeleccionado => _horario;
  bool get estaCargandoHorarios => _estaCargandoHorarios;
  bool get estaGuardando => _estaGuardando;
  String? get error => _error;

  List<String> get horariosDisponibles =>
      List.unmodifiable(_horariosDisponibles);

  /// Especialidades sin repetir.
  List<String> get especialidades => List.unmodifiable(
        _profesionales.map((p) => p.especialidad).toSet(),
      );

  /// Nombres de los profesionales de la especialidad elegida.
  List<String> get profesionalesDisponibles => List.unmodifiable(
        _profesionales
            .where((p) => p.especialidad == _especialidad)
            .map((p) => p.nombre),
      );

  bool get puedeElegirProfesional => _especialidad != null;

  /// El horario se elige recien con profesional y fecha.
  bool get puedeElegirHorario =>
      _profesional != null && _fecha != null && !_estaCargandoHorarios;

  String get fechaTexto {
    final fecha = _fecha;
    return fecha == null ? 'Seleccionar fecha' : formatearFecha(fecha);
  }

  String? get ayudaHorario => puedeElegirHorario && _horariosDisponibles.isEmpty
      ? 'No hay horarios libres ese día.'
      : null;

  DateTime get fechaMinima => Turno.soloDia(DateTime.now());

  DateTime get fechaMaxima =>
      fechaMinima.add(const Duration(days: diasMaximosAnticipacion));

  DateTime get fechaInicialSelector => _fecha ?? fechaMinima;

  /// Carga profesionales y paciente, y restaura el borrador si existe.
  Future<void> cargar() async {
    _estado = EstadoCarga.cargando;
    notifyListeners();

    try {
      _profesionales = await _turnoRepository.obtenerProfesionales();
      final uid = _authRepository.uidActual;
      _paciente =
          uid == null ? null : await _perfilRepository.obtenerPerfil(uid);
      await _restaurarBorrador();
      _estado = EstadoCarga.exito;
    } catch (_) {
      _estado = EstadoCarga.error;
    }
    notifyListeners();
  }

  /// Vuelve a cargar los datos al retomar la app.
  Future<void> refrescar() => cargar();

  /// Guarda la seleccion actual como borrador.
  Future<void> guardarBorrador() {
    return _borradorRepository.guardarBorradorTurno(
      BorradorTurno(
        especialidad: _especialidad,
        profesional: _profesional,
        fecha: _fecha,
        horario: _horario,
      ),
    );
  }

  void seleccionarEspecialidad(String? especialidad) {
    _especialidad = especialidad;
    _profesional = null;
    _horario = null;
    _horariosDisponibles = [];
    _error = null;
    notifyListeners();
    unawaited(guardarBorrador());
  }

  Future<void> seleccionarProfesional(String? profesional) async {
    _profesional = profesional;
    _horario = null;
    _error = null;
    await _cargarHorarios();
    unawaited(guardarBorrador());
  }

  Future<void> seleccionarFecha(DateTime fecha) async {
    _fecha = fecha;
    _horario = null;
    _error = null;
    await _cargarHorarios();
    unawaited(guardarBorrador());
  }

  void seleccionarHorario(String? horario) {
    _horario = horario;
    _error = null;
    notifyListeners();
    unawaited(guardarBorrador());
  }

  /// Valida y guarda el turno. Devuelve el turno guardado, o null si fallo.
  Future<Turno?> confirmar() async {
    final especialidad = _especialidad;
    final profesional = _profesional;
    final fecha = _fecha;
    final horario = _horario;
    final pacienteUid = _paciente?.uid ?? _authRepository.uidActual;

    if (especialidad == null ||
        profesional == null ||
        fecha == null ||
        horario == null ||
        pacienteUid == null) {
      _error = 'Completá todos los datos del turno.';
      notifyListeners();
      return null;
    }

    _estaGuardando = true;
    _error = null;
    notifyListeners();

    try {
      final turno = await _turnoRepository.guardarTurno(
        Turno(
          pacienteUid: pacienteUid,
          especialidad: especialidad,
          profesional: profesional,
          fecha: fecha,
          horario: horario,
        ),
      );
      await _programarRecordatorio(turno);
      await _borradorRepository.eliminarBorradorTurno();
      _busDeEventos.publicar(
        TurnoConfirmadoEvento(
          especialidad: especialidad,
          profesional: profesional,
          fecha: fecha,
        ),
      );
      _limpiarSeleccion();
      return turno;
    } on TurnoNoDisponibleException {
      _error = 'Ese horario se acaba de ocupar. Elegí otro.';
      _horario = null;
      await _cargarHorarios();
      return null;
    } catch (_) {
      _error = 'No se pudo guardar el turno. Probá de nuevo.';
      return null;
    } finally {
      _estaGuardando = false;
      notifyListeners();
    }
  }

  /// Un fallo al programar el aviso no debe deshacer la reserva.
  Future<void> _programarRecordatorio(Turno turno) async {
    try {
      await _recordatorioRepository.programarRecordatorio(turno);
    } catch (_) {
      return;
    }
  }

  Future<void> _restaurarBorrador() async {
    _limpiarSeleccion();
    final borrador = _borradorRepository.obtenerBorradorTurno();

    if (!especialidades.contains(borrador.especialidad)) return;
    _especialidad = borrador.especialidad;

    if (!profesionalesDisponibles.contains(borrador.profesional)) return;
    _profesional = borrador.profesional;

    final fecha = borrador.fecha;
    if (fecha == null || fecha.isBefore(fechaMinima)) return;
    _fecha = fecha;

    await _cargarHorarios();
    if (_horariosDisponibles.contains(borrador.horario)) {
      _horario = borrador.horario;
    }
  }

  void _limpiarSeleccion() {
    _especialidad = null;
    _profesional = null;
    _fecha = null;
    _horario = null;
    _horariosDisponibles = [];
    _error = null;
  }

  /// Pide al repositorio los horarios libres del profesional en la fecha.
  Future<void> _cargarHorarios() async {
    final profesional = _profesional;
    final fecha = _fecha;
    if (profesional == null || fecha == null) {
      _horariosDisponibles = [];
      notifyListeners();
      return;
    }

    _estaCargandoHorarios = true;
    notifyListeners();

    try {
      _horariosDisponibles =
          await _turnoRepository.listarHorariosDisponibles(profesional, fecha);
    } catch (_) {
      _horariosDisponibles = [];
      _error = 'No se pudieron cargar los horarios.';
    } finally {
      _estaCargandoHorarios = false;
      notifyListeners();
    }
  }
}
