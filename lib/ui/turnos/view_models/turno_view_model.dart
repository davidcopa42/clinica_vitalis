import 'package:clinica_vitalis/data/repositories/borrador_repository.dart';
import 'package:clinica_vitalis/data/repositories/recordatorio_repository.dart';
import 'package:clinica_vitalis/data/repositories/turno_repository.dart';
import 'package:clinica_vitalis/domain/models/borrador_turno.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/profesional.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';
import 'package:clinica_vitalis/ui/core/formato.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/models/evento_de_app.dart';
import '../../../data/services/bus_de_eventos.dart';

/// Estado y lógica de la pantalla Solicitar turno.
class TurnoViewModel extends ChangeNotifier {
  TurnoViewModel({
    required TurnoRepository repositorio,
    required BorradorRepository borradorRepository,
    required RecordatorioRepository recordatorioRepository,
    required BusDeEventos busDeEventos,
  })  : _repositorio = repositorio,
        _borradorRepository = borradorRepository,
        _recordatorioRepository = recordatorioRepository,
        _busDeEventos = busDeEventos;

  final TurnoRepository _repositorio;
  final BorradorRepository _borradorRepository;
  final RecordatorioRepository _recordatorioRepository;
  final BusDeEventos _busDeEventos;

  // ---------- Estado privado ----------

  EstadoCarga _estado = EstadoCarga.inicial;
  List<Profesional> _profesionales = [];
  String? _especialidadSeleccionada;
  String? _profesionalSeleccionado;
  DateTime? _fechaSeleccionada;
  String? _horarioSeleccionado;
  List<String> _horariosDisponibles = [];
  bool _cargandoHorarios = false;
  bool _guardando = false;
  String? _error;

  // ---------- Lo que la vista puede leer ----------

  EstadoCarga get estado => _estado;
  String? get especialidadSeleccionada => _especialidadSeleccionada;
  String? get profesionalSeleccionado => _profesionalSeleccionado;
  DateTime? get fechaSeleccionada => _fechaSeleccionada;
  String? get horarioSeleccionado => _horarioSeleccionado;
  List<String> get horariosDisponibles =>
      List.unmodifiable(_horariosDisponibles);
  bool get cargandoHorarios => _cargandoHorarios;
  bool get guardando => _guardando;
  String? get error => _error;

  /// Especialidades sin repetir.
  List<String> get especialidades => List.unmodifiable(
        _profesionales.map((profesional) => profesional.especialidad).toSet(),
      );

  /// Profesionales de la especialidad elegida.
  List<Profesional> get profesionalesDisponibles => List.unmodifiable(
        _profesionales.where(
          (profesional) => profesional.especialidad == _especialidadSeleccionada,
        ),
      );

  /// El horario se elige recién con profesional y fecha.
  bool get puedeElegirHorario =>
      _profesionalSeleccionado != null &&
          _fechaSeleccionada != null &&
          !_cargandoHorarios;

  /// El profesional se elige recién con especialidad.
  bool get puedeElegirProfesional => _especialidadSeleccionada != null;

  /// Fecha elegida con formato dd/mm/aaaa, o la invitación a elegirla.
  String get fechaTexto {
    final fecha = _fechaSeleccionada;
    return fecha == null ? 'Seleccionar fecha' : formatearFecha(fecha);
  }

  /// Aviso cuando ya se puede elegir horario pero no queda ninguno libre.
  String? get avisoSinHorarios =>
      puedeElegirHorario && _horariosDisponibles.isEmpty
          ? 'No hay horarios libres ese día.'
          : null;

  // ---------- Acciones de Persistencia Local (Borrador) ----------

  /// Guarda los datos actuales de forma inmediata en el borrador.
  Future<void> guardarBorrador() async {
    await _borradorRepository.guardarBorradorTurno(
      BorradorTurno(
        especialidad: _especialidadSeleccionada,
        profesional: _profesionalSeleccionado,
        fecha: _fechaSeleccionada,
        horario: _horarioSeleccionado,
      ),
    );

    debugPrint('Ciclo de vida - Borrador actualizado en SharedPreferences.');
  }

  /// Refresca los datos del servidor cuando la app vuelve al frente (onResume)
  Future<void> refrescar() async {
    debugPrint('Ciclo de vida - App retomada. Refrescando cartelera de turnos...');
    await cargar();
  }

  /// Carga los profesionales al abrir la pantalla y recupera todo el borrador si existe.
  Future<void> cargar() async {
    _estado = EstadoCarga.cargando;
    notifyListeners();

    try {
      _profesionales = await _repositorio.obtenerProfesionales();
      final borrador = await _borradorRepository.obtenerBorradorTurno();
      await _restaurarBorrador(borrador);

      _estado = EstadoCarga.exito;
    } catch (_) {
      _estado = EstadoCarga.error;
    }

    notifyListeners();
  }

  void seleccionarEspecialidad(String? especialidad) {
    _especialidadSeleccionada = especialidad;
    _profesionalSeleccionado = null;
    _horarioSeleccionado = null;
    _horariosDisponibles = [];
    _error = null;
    notifyListeners();
    guardarBorrador();
  }

  Future<void> seleccionarProfesional(String? profesional) async {
    _profesionalSeleccionado = profesional;
    _horarioSeleccionado = null;
    _error = null;
    await _cargarHorarios();
    notifyListeners();
    guardarBorrador();
  }

  Future<void> seleccionarFecha(DateTime fecha) async {
    _fechaSeleccionada = fecha;
    _horarioSeleccionado = null;
    _error = null;
    await _cargarHorarios();
    notifyListeners();
    guardarBorrador();
  }

  void seleccionarHorario(String? horario) {
    _horarioSeleccionado = horario;
    _error = null;
    notifyListeners();
    guardarBorrador();
  }

  /// Valida y guarda el turno, y programa su recordatorio.
  ///
  /// Devuelve el turno guardado, o null si falló
  Future<Turno?> confirmar(Paciente paciente) async {
    if (_especialidadSeleccionada == null ||
        _profesionalSeleccionado == null ||
        _fechaSeleccionada == null ||
        _horarioSeleccionado == null) {
      _error = 'Completá todos los datos del turno.';
      notifyListeners();
      return null;
    }

    _guardando = true;
    _error = null;
    notifyListeners();

    late final Turno turnoGuardado;
    try {
      turnoGuardado = await _repositorio.guardarTurno(
        Turno(
          pacienteUid: paciente.uid,
          especialidad: _especialidadSeleccionada!,
          profesional: _profesionalSeleccionado!,
          fecha: _fechaSeleccionada!,
          horario: _horarioSeleccionado!,
        ),
      );

      // Limpiamos el borrador al confirmar el turno con éxito
      await _borradorRepository.borrarBorradorTurno();

      // ---> 2. PUBLICAMOS EL EVENTO EN EL STREAM (El Micrófono) <---
      _busDeEventos.publicar(
        TurnoConfirmadoEvento(
          especialidad: _especialidadSeleccionada!,
          profesional: _profesionalSeleccionado!,
          fecha: _fechaSeleccionada!,
        ),
      );
    } on TurnoNoDisponibleException {
      _error = 'Ese horario se acaba de ocupar. Elegí otro.';
      _horarioSeleccionado = null;
      await _cargarHorarios();
      return null;
    } catch (_) {
      _error = 'No se pudo guardar el turno. Probá de nuevo.';
      return null;
    } finally {
      _guardando = false;
      notifyListeners();
    }

    // Fuera del try: si falla, el error se propaga a la vista como antes.
    await _recordatorioRepository.programarRecordatorio(turnoGuardado);
    return turnoGuardado;
  }

  /// Restaura del borrador lo que siga siendo válido, en orden:
  /// especialidad, profesional, fecha, horarios libres y horario.
  ///
  /// Si un paso no es válido, deja de restaurar los siguientes.
  Future<void> _restaurarBorrador(BorradorTurno borrador) async {
    final especialidadGuardada = borrador.especialidad;
    if (especialidadGuardada == null ||
        !especialidades.contains(especialidadGuardada)) {
      return;
    }
    _especialidadSeleccionada = especialidadGuardada;

    final profesionalGuardado = borrador.profesional;
    final profesionalEsValido = profesionalesDisponibles
        .any((profesional) => profesional.nombre == profesionalGuardado);
    if (profesionalGuardado == null || !profesionalEsValido) return;
    _profesionalSeleccionado = profesionalGuardado;

    final fechaGuardada = borrador.fecha;
    if (fechaGuardada != null) _fechaSeleccionada = fechaGuardada;

    // Usa la fecha ya elegida aunque el borrador no tenga una.
    final fecha = _fechaSeleccionada;
    if (fecha != null) {
      try {
        _horariosDisponibles =
            await _repositorio.horariosDisponibles(profesionalGuardado, fecha);
      } catch (_) {
        _horariosDisponibles = [];
      }
    }

    final horarioGuardado = borrador.horario;
    if (horarioGuardado != null &&
        _horariosDisponibles.contains(horarioGuardado)) {
      _horarioSeleccionado = horarioGuardado;
    }
  }

  /// Pide al repositorio los horarios libres del profesional en la fecha.
  Future<void> _cargarHorarios() async {
    if (_profesionalSeleccionado == null || _fechaSeleccionada == null) {
      _horariosDisponibles = [];
      notifyListeners();
      return;
    }

    _cargandoHorarios = true;
    notifyListeners();

    try {
      _horariosDisponibles = await _repositorio.horariosDisponibles(
        _profesionalSeleccionado!,
        _fechaSeleccionada!,
      );
    } catch (_) {
      _horariosDisponibles = [];
      _error = 'No se pudieron cargar los horarios.';
    } finally {
      _cargandoHorarios = false;
      notifyListeners();
    }
  }
}