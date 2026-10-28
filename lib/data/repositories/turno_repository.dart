import 'package:clinica_vitalis/data/services/base_datos_service.dart';
import 'package:clinica_vitalis/data/services/datos_ejemplo.dart';
import 'package:clinica_vitalis/domain/models/profesional.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';

/// Se lanza cuando se intenta reservar un horario que ya no está libre.
class TurnoNoDisponibleException implements Exception {
  const TurnoNoDisponibleException();

  @override
  String toString() => 'Ese horario ya no está disponible.';
}

/// Obtiene y guarda turnos. Es lo único que usan los ViewModels
/// para acceder a los turnos.
class TurnoRepository {
  TurnoRepository({BaseDatosService? baseDatos})
      : _baseDatos = baseDatos ?? BaseDatosService();

  final BaseDatosService _baseDatos;

  /// Profesionales de la clínica.
  ///
  /// Hoy son datos de ejemplo. Es Future para que, si mañana vienen
  /// de una API, no haya que cambiar a quien lo usa.
  Future<List<Profesional>> obtenerProfesionales() async {
    return profesionalesDeEjemplo;
  }

  /// Turnos confirmados y futuros del paciente, del más cercano al más lejano.
  Future<List<Turno>> obtenerTurnos(String pacienteUid) async {
    final filas = await _baseDatos.consultar(
      where: 'paciente_uid = ? AND estado = ?',
      whereArgs: [pacienteUid, EstadoTurno.confirmado.name],
    );

    final ahora = DateTime.now();
    final turnos = filas
        .map(Turno.fromMap)
        .where((turno) => turno.fechaHora.isAfter(ahora))
        .toList();

    turnos.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
    return turnos;
  }

  /// Guarda el turno y lo devuelve con el id que le asignó la base.
  ///
  /// Lanza [TurnoNoDisponibleException] si el horario ya está ocupado.
  Future<Turno> guardarTurno(Turno turno) async {
    final libres = await horariosDisponibles(turno.profesional, turno.fecha);
    if (!libres.contains(turno.horario)) {
      throw const TurnoNoDisponibleException();
    }

    final id = await _baseDatos.insertar(turno.toMap());
    return turno.copyWith(id: id);
  }

  /// Marca el turno como cancelado. No se borra, queda en el historial.
  Future<void> cancelarTurno(int id) async {
    await _baseDatos.actualizar(id, {'estado': EstadoTurno.cancelado.name});
  }

  /// Horarios libres de un profesional en una fecha.
  ///
  /// Saca los ya reservados por cualquier paciente y, si la fecha es hoy,
  /// los que ya pasaron.
  Future<List<String>> horariosDisponibles(
      String profesional,
      DateTime fecha,
      ) async {
    final profesionales = await obtenerProfesionales();
    final elegido = profesionales.where((p) => p.nombre == profesional);
    if (elegido.isEmpty) return [];

    final filas = await _baseDatos.consultar(
      where: 'profesional = ? AND fecha = ? AND estado = ?',
      whereArgs: [
        profesional,
        _soloDia(fecha).toIso8601String(),
        EstadoTurno.confirmado.name,
      ],
    );
    final ocupados = filas.map((fila) => fila['horario'] as String).toSet();

    final ahora = DateTime.now();
    return elegido.first.horarios
        .where((horario) => !ocupados.contains(horario))
        .where((horario) => _combinar(fecha, horario).isAfter(ahora))
        .toList();
  }

  /// Deja solo día, mes y año (hora 00:00).
  DateTime _soloDia(DateTime fecha) =>
      DateTime(fecha.year, fecha.month, fecha.day);

  /// Junta una fecha con un horario 'HH:mm'.
  DateTime _combinar(DateTime fecha, String horario) {
    final partes = horario.split(':');
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      int.parse(partes[0]),
      int.parse(partes[1]),
    );
  }
}