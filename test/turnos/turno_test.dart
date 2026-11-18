import 'package:clinica_vitalis/data/repositories/turno_repository.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:clinica_vitalis/ui/turnos/view_models/turno_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base_datos_service_falso.dart';

/// Mañana a las 00:00, para que ningún horario cuente como "ya pasado".
DateTime manana() {
  final dia = DateTime.now().add(const Duration(days: 1));
  return DateTime(dia.year, dia.month, dia.day);
}

void main() {
  late TurnoRepository repositorio;

  setUp(() {
    // Simula el almacenamiento del celular: el ViewModel guarda un borrador.
    SharedPreferences.setMockInitialValues({});
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

  group('procesarTurnos (compute)', () {
    Map<String, Object?> fila(int id, DateTime fecha, String horario) {
      return Turno(
        id: id,
        pacienteUid: 'paciente-de-prueba',
        especialidad: 'Clínica médica',
        profesional: 'Dra. Prueba',
        fecha: fecha,
        horario: horario,
      ).toMap();
    }

    test('descarta los turnos pasados y ordena del más cercano al más lejano',
        () {
      final ahora = DateTime(2026, 11, 18, 12, 0);

      final resultado = procesarTurnos((
        filas: [
          fila(1, DateTime(2026, 11, 20), '10:00'),
          fila(2, DateTime(2026, 11, 18), '09:00'), // ya pasó
          fila(3, DateTime(2026, 11, 18), '15:30'),
          fila(4, DateTime(2026, 11, 19), '08:00'),
        ],
        ahora: ahora,
      ));

      expect(resultado.map((t) => t.id), [3, 4, 1]);
    });

    test('obtenerTurnos devuelve los turnos procesados en el isolate',
        () async {
      final profesional = (await repositorio.obtenerProfesionales()).first;
      final pasadoManana = manana().add(const Duration(days: 1));

      for (final fecha in [pasadoManana, manana()]) {
        await repositorio.guardarTurno(
          Turno(
            pacienteUid: 'paciente-de-prueba',
            especialidad: profesional.especialidad,
            profesional: profesional.nombre,
            fecha: fecha,
            horario: profesional.horarios.first,
          ),
        );
      }

      final turnos = await repositorio.obtenerTurnos('paciente-de-prueba');

      expect(turnos.map((t) => t.fecha), [manana(), pasadoManana]);
    });
  });
}
