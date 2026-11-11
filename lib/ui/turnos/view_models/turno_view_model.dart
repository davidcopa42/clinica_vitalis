import 'package:clinica_vitalis/data/repositories/turno_repository.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/profesional.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // ---------- Acciones de Persistencia Local (Borrador) ----------

  /// Guarda los datos actuales de forma inmediata en SharedPreferences
  Future<void> guardarBorrador() async {
    final prefs = await SharedPreferences.getInstance();

    if (_especialidadSeleccionada != null) {
      await prefs.setString('borrador_especialidad', _especialidadSeleccionada!);
    } else {
      await prefs.remove('borrador_especialidad');
    }

    if (_profesionalSeleccionado != null) {
      await prefs.setString('borrador_profesional', _profesionalSeleccionado!);
    } else {
      await prefs.remove('borrador_profesional');
    }

    if (_fechaSeleccionada != null) {
      await prefs.setString('borrador_fecha', _fechaSeleccionada!.toIso8601String());
    } else {
      await prefs.remove('borrador_fecha');
    }

    if (_horarioSeleccionado != null) {
      await prefs.setString('borrador_horario', _horarioSeleccionado!);
    } else {
      await prefs.remove('borrador_horario');
    }

    debugPrint('Ciclo de vida - Borrador actualizado en SharedPreferences.');
  }

  /// Refresca los datos del servidor cuando la app vuelve al frente (onResume)
  Future<void> refrescar() async {
    debugPrint('Ciclo de vida - App retomada. Refrescando cartelera de turnos...');
    await cargar();
  }

  /// Carga los profesionales al abrir la pantalla y recupera el borrador si existe.
  /// Carga los profesionales al abrir la pantalla y recupera todo el borrador si existe.
  Future<void> cargar() async {
    _estado = EstadoCarga.cargando;
    notifyListeners();

    try {
      // 1. Primero obtenemos la lista de profesionales del repositorio
      _profesionales = await _repositorio.obtenerProfesionales();

      // 2. Leemos el borrador guardado en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final espGuardada = prefs.getString('borrador_especialidad');
      final profGuardado = prefs.getString('borrador_profesional');
      final fechaGuardadaStr = prefs.getString('borrador_fecha');
      final horarioGuardado = prefs.getString('borrador_horario');

      // 3. Restauramos la especialidad si es válida
      if (espGuardada != null && especialidades.contains(espGuardada)) {
        _especialidadSeleccionada = espGuardada;

        // 4. Restauramos el profesional si existe
        if (profGuardado != null && profesionalesDisponibles.any((p) => p.nombre == profGuardado)) {
          _profesionalSeleccionado = profGuardado;

          // 5. Restauramos la fecha si está guardada
          if (fechaGuardadaStr != null) {
            _fechaSeleccionada = DateTime.parse(fechaGuardadaStr);
          }

          // 6. SOLUCIÓN CLAVE: Si ya tenemos profesional y fecha, cargamos los horarios de forma sincrónica/esperada
          if (_fechaSeleccionada != null) {
            try {
              _horariosDisponibles = await _repositorio.horariosDisponibles(
                _profesionalSeleccionado!,
                _fechaSeleccionada!,
              );
            } catch (_) {
              _horariosDisponibles = [];
            }
          }

          // 7. Finalmente, restauramos el horario si está dentro de los disponibles
          if (horarioGuardado != null && _horariosDisponibles.contains(horarioGuardado)) {
            _horarioSeleccionado = horarioGuardado;
          }
        }
      }

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
    guardarBorrador(); // <--- Guardamos al instante cada cambio
  }

  Future<void> seleccionarProfesional(String? profesional) async {
    _profesionalSeleccionado = profesional;
    _horarioSeleccionado = null;
    _error = null;
    await _cargarHorarios();
    notifyListeners();
    guardarBorrador(); // <--- Guardamos al instante cada cambio
  }

  Future<void> seleccionarFecha(DateTime fecha) async {
    _fechaSeleccionada = fecha;
    _horarioSeleccionado = null;
    _error = null;
    await _cargarHorarios();
    notifyListeners();
    guardarBorrador(); // <--- Guardamos al instante cada cambio
  }

  void seleccionarHorario(String? horario) {
    _horarioSeleccionado = horario;
    _error = null;
    notifyListeners();
    guardarBorrador(); // <--- Guardamos al instante cada cambio
  }

  /// Valida y guarda el turno. Devuelve el turno guardado, o null si falló
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
      final turnoGuardado = await _repositorio.guardarTurno(
        Turno(
          pacienteUid: paciente.uid,
          especialidad: _especialidadSeleccionada!,
          profesional: _profesionalSeleccionado!,
          fecha: _fechaSeleccionada!,
          horario: _horarioSeleccionado!,
        ),
      );

      // Limpiamos el borrador de SharedPreferences al confirmar el turno con éxito
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('borrador_especialidad');
      await prefs.remove('borrador_profesional');
      await prefs.remove('borrador_fecha');
      await prefs.remove('borrador_horario');

      return turnoGuardado;
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