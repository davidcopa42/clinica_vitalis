import 'package:clinica_vitalis/data/repositories/turno_repository.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:clinica_vitalis/ui/turnos/view_models/turno_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_datos_service_falso.dart';

/// Mañana a las 00:00, para que ningún horario cuente como "ya pasado".
DateTime manana() {
  final dia = DateTime.now().add(const Duration(days: 1));
  return DateTime(dia.year, dia.month, dia.day);
}

void main() {
  late TurnoRepository repositorio;

  setUp(() {
    // Repositorio real con base en memoria: cada test arranca vacío.
    repositorio = TurnoRepository(baseDatos: BaseDatosServiceFalso());
  });

  group('TurnoViewModel', () {
    test('cambiar la especialidad resetea el profesional', () async {
      final viewModel = TurnoViewModel(repositorio: repositorio);
      await viewModel.cargar();

      viewModel.seleccionarEspecialidad(viewModel.especialidades.first);
      await viewModel.seleccionarProfesional(
        viewModel.profesionalesDisponibles.first.nombre,
      );
      expect(viewModel.profesionalSeleccionado, isNotNull);

      viewModel.seleccionarEspecialidad(viewModel.especialidades.last);

      expect(viewModel.profesionalSeleccionado, isNull);
      expect(viewModel.horarioSeleccionado, isNull);
      expect(viewModel.horariosDisponibles, isEmpty);
    });
  });

  group('TurnoRepository', () {
    test('un horario reservado no aparece como disponible', () async {
      final profesional = (await repositorio.obtenerProfesionales()).first;
      final horario = profesional.horarios.first;

      final antes =
          await repositorio.horariosDisponibles(profesional.nombre, manana());
      expect(antes, contains(horario));

      await repositorio.guardarTurno(
        Turno(
          pacienteUid: 'paciente-de-prueba',
          especialidad: profesional.especialidad,
          profesional: profesional.nombre,
          fecha: manana(),
          horario: horario,
        ),
      );

      final despues =
          await repositorio.horariosDisponibles(profesional.nombre, manana());
      expect(despues, isNot(contains(horario)));
    });

    test('no se puede reservar dos veces el mismo horario', () async {
      final profesional = (await repositorio.obtenerProfesionales()).first;
      final turno = Turno(
        pacienteUid: 'paciente-de-prueba',
        especialidad: profesional.especialidad,
        profesional: profesional.nombre,
        fecha: manana(),
        horario: profesional.horarios.first,
      );

      await repositorio.guardarTurno(turno);

      expect(
        () => repositorio.guardarTurno(turno),
        throwsA(isA<TurnoNoDisponibleException>()),
      );
    });
  });
}
