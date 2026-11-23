import 'dart:async';

import 'package:clinica_vitalis/data/repositories/turno_no_disponible_exception.dart';
import 'package:clinica_vitalis/data/repositories/turno_repository.dart';
import 'package:clinica_vitalis/domain/models/profesional.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';

/// [TurnoRepository] en memoria para los tests.
class FakeTurnoRepository implements TurnoRepository {
  FakeTurnoRepository({List<Turno>? turnos}) : turnos = turnos ?? [];

  static const profesionales = [
    Profesional(
      nombre: 'Dra. Ana López',
      especialidad: 'Clínica Médica',
      horarios: ['09:00', '09:30'],
    ),
  ];

  final List<Turno> turnos;
  final List<int> cancelados = [];
  bool horarioOcupado = false;

  /// Si no es null, [cancelarTurno] espera a que se complete.
  Completer<void>? esperaCancelacion;

  @override
  Future<List<Profesional>> obtenerProfesionales() async => profesionales;

  @override
  Future<List<Turno>> obtenerTurnos(String pacienteUid) async =>
      turnos.where((turno) => turno.pacienteUid == pacienteUid).toList();

  @override
  Future<Turno> guardarTurno(Turno turno) async {
    if (horarioOcupado) throw const TurnoNoDisponibleException();
    final guardado = turno.copyWith(id: turnos.length + 1);
    turnos.add(guardado);
    return guardado;
  }

  @override
  Future<void> cancelarTurno(int id) async {
    await esperaCancelacion?.future;
    cancelados.add(id);
  }

  @override
  Future<List<String>> listarHorariosDisponibles(
    String profesional,
    DateTime fecha,
  ) async =>
      profesionales.first.horarios;
}
