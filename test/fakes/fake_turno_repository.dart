import 'dart:async';

import 'package:clinica_vitalis/data/repositories/turno_repository.dart';
import 'package:clinica_vitalis/domain/models/profesional.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';

/// Repositorio de turnos falso y configurable para los tests de ViewModels.
class FakeTurnoRepository implements TurnoRepository {
  FakeTurnoRepository({
    this.profesionales = const [],
    List<Turno>? turnos,
    List<String>? horarios,
  })  : turnos = turnos ?? [],
        horarios = horarios ?? [];

  List<Profesional> profesionales;
  List<Turno> turnos;
  List<String> horarios;

  /// Si no es null, el metodo correspondiente lanza este error.
  Object? errorAlObtenerProfesionales;
  Object? errorAlObtenerTurnos;
  Object? errorAlObtenerHorarios;
  Object? errorAlGuardar;
  Object? errorAlCancelar;

  /// Si no es null, [cancelarTurno] espera a que se complete.
  Completer<void>? bloqueoAlCancelar;

  final List<String> pacientesConsultados = [];
  final List<(String, DateTime)> consultasDeHorarios = [];
  final List<Turno> turnosGuardados = [];
  final List<int> turnosCancelados = [];

  int _proximoId = 100;

  @override
  Future<List<Profesional>> obtenerProfesionales() async {
    if (errorAlObtenerProfesionales != null) throw errorAlObtenerProfesionales!;
    return profesionales;
  }

  @override
  Future<List<Turno>> obtenerTurnos(String pacienteUid) async {
    pacientesConsultados.add(pacienteUid);
    if (errorAlObtenerTurnos != null) throw errorAlObtenerTurnos!;
    return List.of(turnos);
  }

  @override
  Future<List<String>> horariosDisponibles(
    String profesional,
    DateTime fecha,
  ) async {
    consultasDeHorarios.add((profesional, fecha));
    if (errorAlObtenerHorarios != null) throw errorAlObtenerHorarios!;
    return List.of(horarios);
  }

  @override
  Future<Turno> guardarTurno(Turno turno) async {
    turnosGuardados.add(turno);
    if (errorAlGuardar != null) throw errorAlGuardar!;
    return turno.copyWith(id: _proximoId++);
  }

  @override
  Future<void> cancelarTurno(int id) async {
    turnosCancelados.add(id);
    await bloqueoAlCancelar?.future;
    if (errorAlCancelar != null) throw errorAlCancelar!;
  }
}
