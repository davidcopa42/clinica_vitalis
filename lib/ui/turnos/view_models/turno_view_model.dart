import 'package:flutter/foundation.dart';

import 'package:clinica_vitalis/data/repositories/turno_repository.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/profesional.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';

/// Estado y lógica de la pantalla Solicitar turno.
class TurnoViewModel extends ChangeNotifier {
  TurnoViewModel({required TurnoRepository repositorio})
      : _repositorio = repositorio;

  final TurnoRepository _repositorio;

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
  List<String> get especialidades =>
      _profesionales.map((p) => p.especialidad).toSet().toList();

  /// Profesionales de la especialidad elegida.
  List<Profesional> get profesionalesDisponibles => _profesionales
      .where((p) => p.especialidad == _especialidadSeleccionada)
      .toList();

  /// El horario se elige recién con profesional y fecha.
  bool get puedeElegirHorario =>
      _profesionalSeleccionado != null &&
          _fechaSeleccionada != null &&
          !_cargandoHorarios;

  // ---------- Acciones ----------

  /// Carga los profesionales al abrir la pantalla.
  Future<void> cargar() async {
    _estado = EstadoCarga.cargando;
    notifyListeners();

    try {
      _profesionales = await _repositorio.obtenerProfesionales();
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
  }

  Future<void> seleccionarProfesional(String? profesional) async {
    _profesionalSeleccionado = profesional;
    _horarioSeleccionado = null;
    _error = null;
    await _cargarHorarios();
  }

  Future<void> seleccionarFecha(DateTime fecha) async {
    _fechaSeleccionada = fecha;
    _horarioSeleccionado = null;
    _error = null;
    await _cargarHorarios();
  }

  void seleccionarHorario(String? horario) {
    _horarioSeleccionado = horario;
    _error = null;
    notifyListeners();
  }

  /// Valida y guarda el turno. Devuelve el turno guardado, o null si falló
  /// (en ese caso [error] explica por qué).
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

    try {
      return await _repositorio.guardarTurno(
        Turno(
          // TODO: reemplazar por paciente.uid cuando esté el login.
          pacienteUid: paciente.correo,
          especialidad: _especialidadSeleccionada!,
          profesional: _profesionalSeleccionado!,
          fecha: _fechaSeleccionada!,
          horario: _horarioSeleccionado!,
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