import 'package:clinica_vitalis/domain/models/profesional.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';

/// Se lanza cuando se intenta reservar un horario que ya no está libre.
class TurnoNoDisponibleException implements Exception {
  const TurnoNoDisponibleException();

  @override
  String toString() => 'Ese horario ya no está disponible.';
}

/// Contrato para obtener y guardar turnos. Es lo único que usan los
/// ViewModels para acceder a los turnos.
abstract class TurnoRepository {
  /// Profesionales de la clínica.
  Future<List<Profesional>> obtenerProfesionales();

  /// Turnos confirmados y futuros del paciente, del más cercano al más lejano.
  Future<List<Turno>> obtenerTurnos(String pacienteUid);

  /// Guarda el turno y lo devuelve con el id que le asignó la base.
  ///
  /// Lanza [TurnoNoDisponibleException] si el horario ya está ocupado.
  Future<Turno> guardarTurno(Turno turno);

  /// Marca el turno como cancelado. No se borra, queda en el historial.
  Future<void> cancelarTurno(int id);

  /// Horarios libres de un profesional en una fecha.
  Future<List<String>> horariosDisponibles(String profesional, DateTime fecha);
}
