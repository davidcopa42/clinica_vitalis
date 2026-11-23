import '../../domain/models/profesional.dart';
import '../../domain/models/turno.dart';

/// Contrato para obtener y guardar turnos.
abstract class TurnoRepository {
  /// Profesionales de la clinica.
  Future<List<Profesional>> obtenerProfesionales();

  /// Turnos confirmados y futuros del paciente, del mas cercano al mas lejano.
  Future<List<Turno>> obtenerTurnos(String pacienteUid);

  /// Guarda el turno y lo devuelve con el id asignado.
  ///
  /// Lanza [TurnoNoDisponibleException] si el horario ya esta ocupado.
  Future<Turno> guardarTurno(Turno turno);

  /// Marca el turno como cancelado. No se borra, queda en el historial.
  Future<void> cancelarTurno(int id);

  /// Horarios libres de un [profesional] en una [fecha].
  Future<List<String>> listarHorariosDisponibles(
    String profesional,
    DateTime fecha,
  );
}
