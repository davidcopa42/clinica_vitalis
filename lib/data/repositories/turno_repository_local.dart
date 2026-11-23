import '../../domain/models/profesional.dart';
import '../../domain/models/turno.dart';
import '../services/base_datos_service.dart';
import '../services/profesionales_ejemplo_service.dart';
import 'turno_no_disponible_exception.dart';
import 'turno_repository.dart';

/// Implementacion de [TurnoRepository] sobre SQLite y profesionales de ejemplo.
class TurnoRepositoryLocal implements TurnoRepository {
  TurnoRepositoryLocal({
    required BaseDatosService baseDatosService,
    required ProfesionalesEjemploService profesionalesService,
  })  : _baseDatos = baseDatosService,
        _profesionalesService = profesionalesService;

  final BaseDatosService _baseDatos;
  final ProfesionalesEjemploService _profesionalesService;
  List<Profesional>? _profesionalesEnCache;

  @override
  Future<List<Profesional>> obtenerProfesionales() async {
    final cache = _profesionalesEnCache;
    if (cache != null) return cache;

    final filas = await _profesionalesService.obtenerProfesionales();
    final profesionales =
        List<Profesional>.unmodifiable(filas.map(Profesional.fromMap));
    _profesionalesEnCache = profesionales;
    return profesionales;
  }

  @override
  Future<List<Turno>> obtenerTurnos(String pacienteUid) async {
    final filas = await _baseDatos.consultar(
      where: 'paciente_uid = ? AND estado = ?',
      whereArgs: [pacienteUid, EstadoTurno.confirmado.name],
    );

    final ahora = DateTime.now();
    final turnos = filas
        .map(Turno.fromMap)
        .where((turno) => turno.fechaHora.isAfter(ahora))
        .toList()
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
    return turnos;
  }

  @override
  Future<Turno> guardarTurno(Turno turno) async {
    final libres =
        await listarHorariosDisponibles(turno.profesional, turno.fecha);
    if (!libres.contains(turno.horario)) {
      throw const TurnoNoDisponibleException();
    }

    final id = await _baseDatos.insertar(turno.toMap());
    return turno.copyWith(id: id);
  }

  @override
  Future<void> cancelarTurno(int id) async {
    await _baseDatos.actualizar(id, {'estado': EstadoTurno.cancelado.name});
  }

  /// Saca los horarios ya reservados por cualquier paciente y, si la fecha
  /// es hoy, los que ya pasaron.
  @override
  Future<List<String>> listarHorariosDisponibles(
    String profesional,
    DateTime fecha,
  ) async {
    final profesionales = await obtenerProfesionales();
    final elegidos = profesionales.where((p) => p.nombre == profesional);
    if (elegidos.isEmpty) return [];

    final filas = await _baseDatos.consultar(
      where: 'profesional = ? AND fecha = ? AND estado = ?',
      whereArgs: [
        profesional,
        Turno.soloDia(fecha).toIso8601String(),
        EstadoTurno.confirmado.name,
      ],
    );
    final ocupados = filas.map((fila) => fila['horario'] as String).toSet();

    final ahora = DateTime.now();
    return elegidos.first.horarios
        .where((horario) => !ocupados.contains(horario))
        .where(
          (horario) =>
              Turno.combinarFechaYHorario(fecha, horario).isAfter(ahora),
        )
        .toList();
  }
}
