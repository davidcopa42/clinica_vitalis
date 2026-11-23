import 'package:clinica_vitalis/data/services/bus_de_eventos.dart';
import 'package:clinica_vitalis/domain/models/evento_de_app.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';
import 'package:clinica_vitalis/ui/turnos/view_models/mis_turnos_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_recordatorio_repository.dart';
import '../fakes/fake_turno_repository.dart';

Turno crearTurno(int? id, String horario) {
  return Turno(
    id: id,
    pacienteUid: 'paciente-1',
    especialidad: 'Cardiología',
    profesional: 'Dr. Juan Pérez',
    fecha: DateTime(2030, 3, 15),
    horario: horario,
  );
}

void main() {
  late BusDeEventos busDeEventos;
  late FakeTurnoRepository repositorio;
  late FakeRecordatorioRepository recordatorios;
  late MisTurnosViewModel viewModel;
  var viewModelDescartado = false;

  setUp(() {
    repositorio = FakeTurnoRepository(
      turnos: [crearTurno(1, '08:00'), crearTurno(2, '08:40')],
    );
    recordatorios = FakeRecordatorioRepository();
    busDeEventos = BusDeEventos();
    viewModel = MisTurnosViewModel(
      repositorio: repositorio,
      recordatorioRepository: recordatorios,
      busDeEventos: busDeEventos,
      pacienteUid: 'paciente-1',
    );
    viewModelDescartado = false;
  });

  tearDown(() {
    if (!viewModelDescartado) viewModel.dispose();
    busDeEventos.dispose();
  });

  group('cargar', () {
    test('empieza en estado inicial y sin turnos', () {
      expect(viewModel.estado, EstadoCarga.inicial);
      expect(viewModel.turnos, isEmpty);
    });

    test('trae los turnos del paciente y queda en exito', () async {
      await viewModel.cargar('paciente-1');

      expect(repositorio.pacientesConsultados, ['paciente-1']);
      expect(viewModel.estado, EstadoCarga.exito);
      expect(viewModel.turnos.map((turno) => turno.id), [1, 2]);
      expect(viewModel.error, isNull);
    });

    test('si falla queda en error, sin turnos y con mensaje', () async {
      repositorio.errorAlObtenerTurnos = Exception('falla');

      await viewModel.cargar('paciente-1');

      expect(viewModel.estado, EstadoCarga.error);
      expect(viewModel.turnos, isEmpty);
      expect(viewModel.error, 'No se pudieron cargar tus turnos.');
    });

    test('la lista de turnos no se puede modificar desde afuera', () async {
      await viewModel.cargar('paciente-1');

      expect(
        () => viewModel.turnos.add(crearTurno(3, '09:20')),
        throwsUnsupportedError,
      );
    });
  });

  group('cancelar', () {
    test('un turno sin id devuelve false y no llama a nadie', () async {
      final cancelado = await viewModel.cancelar(crearTurno(null, '08:00'));

      expect(cancelado, isFalse);
      expect(repositorio.turnosCancelados, isEmpty);
      expect(recordatorios.recordatoriosCancelados, isEmpty);
    });

    test(
        'cancela en el repositorio, quita el recordatorio y lo saca de la lista',
        () async {
      await viewModel.cargar('paciente-1');
      final estadosCancelando = <bool>[];
      viewModel.addListener(
        () => estadosCancelando.add(viewModel.estaCancelando),
      );

      final cancelado = await viewModel.cancelar(viewModel.turnos.first);

      expect(cancelado, isTrue);
      expect(repositorio.turnosCancelados, [1]);
      expect(recordatorios.recordatoriosCancelados, [1]);
      expect(viewModel.turnos.map((turno) => turno.id), [2]);
      expect(estadosCancelando, [true, false]);
      expect(viewModel.estaCancelando, isFalse);
    });

    test('si el repositorio falla devuelve false y conserva el turno',
        () async {
      await viewModel.cargar('paciente-1');
      repositorio.errorAlCancelar = Exception('falla');

      final cancelado = await viewModel.cancelar(viewModel.turnos.first);

      expect(cancelado, isFalse);
      expect(viewModel.error, 'No se pudo cancelar el turno. Probá de nuevo.');
      expect(viewModel.turnos.map((turno) => turno.id), [1, 2]);
      expect(recordatorios.recordatoriosCancelados, isEmpty);
      expect(viewModel.estaCancelando, isFalse);
    });

    test(
        'si falla quitar el recordatorio devuelve false aunque el turno '
        'ya se cancelo en el repositorio', () async {
      await viewModel.cargar('paciente-1');
      recordatorios.errorAlCancelar = Exception('falla');

      final cancelado = await viewModel.cancelar(viewModel.turnos.first);

      expect(cancelado, isFalse);
      expect(repositorio.turnosCancelados, [1]);
      expect(viewModel.turnos.map((turno) => turno.id), [1, 2]);
    });
  });

  group('bus de eventos', () {
    test('al confirmarse un turno recarga la lista del paciente', () async {
      busDeEventos.publicar(
        TurnoConfirmadoEvento(
          especialidad: 'Cardiología',
          profesional: 'Dr. Juan Pérez',
          fecha: DateTime(2030, 3, 15),
        ),
      );
      await pumpEventQueue();

      expect(repositorio.pacientesConsultados, ['paciente-1']);
      expect(viewModel.estado, EstadoCarga.exito);
      expect(viewModel.turnos, hasLength(2));
    });

    test('despues de dispose deja de escuchar el bus', () async {
      viewModel.dispose();
      viewModelDescartado = true;

      busDeEventos.publicar(
        TurnoConfirmadoEvento(
          especialidad: 'Cardiología',
          profesional: 'Dr. Juan Pérez',
          fecha: DateTime(2030, 3, 15),
        ),
      );
      await pumpEventQueue();

      expect(repositorio.pacientesConsultados, isEmpty);
    });

    test('solo escucha el bus que recibio por constructor', () async {
      final otroBus = BusDeEventos();

      otroBus.publicar(
        TurnoConfirmadoEvento(
          especialidad: 'Cardiología',
          profesional: 'Dr. Juan Pérez',
          fecha: DateTime(2030, 3, 15),
        ),
      );
      await pumpEventQueue();
      otroBus.dispose();

      expect(repositorio.pacientesConsultados, isEmpty);
    });
  });
}
