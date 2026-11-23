import 'dart:async';

import 'package:clinica_vitalis/domain/models/evento_de_app.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:clinica_vitalis/ui/core/bus_de_eventos.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';
import 'package:clinica_vitalis/ui/turnos/view_models/mis_turnos_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_recordatorio_repository.dart';
import '../fakes/fake_turno_repository.dart';

Turno crearTurno(int id) => Turno(
      id: id,
      pacienteUid: 'p1',
      especialidad: 'Clínica Médica',
      profesional: 'Dra. Ana López',
      fecha: DateTime(2030, 1, id),
      horario: '09:00',
    );

void main() {
  late FakeTurnoRepository turnoRepository;
  late FakeRecordatorioRepository recordatorioRepository;
  late BusDeEventos busDeEventos;
  late MisTurnosViewModel viewModel;

  setUp(() {
    turnoRepository = FakeTurnoRepository(
      turnos: [crearTurno(1), crearTurno(2)],
    );
    recordatorioRepository = FakeRecordatorioRepository();
    busDeEventos = BusDeEventos();
    viewModel = MisTurnosViewModel(
      turnoRepository: turnoRepository,
      recordatorioRepository: recordatorioRepository,
      authRepository: FakeAuthRepository(uidActual: 'p1'),
      busDeEventos: busDeEventos,
    );
  });

  tearDown(() => busDeEventos.cerrar());

  test('cargar trae los turnos del paciente', () async {
    await viewModel.cargar();

    expect(viewModel.estado, EstadoCarga.exito);
    expect(viewModel.turnos, hasLength(2));
  });

  test('solo el turno que se cancela queda marcado como cancelando', () async {
    await viewModel.cargar();
    final [primero, segundo] = viewModel.turnos;
    turnoRepository.esperaCancelacion = Completer<void>();

    final cancelacion = viewModel.cancelar(primero);

    expect(viewModel.estaCancelandoTurno(primero), isTrue);
    expect(viewModel.estaCancelandoTurno(segundo), isFalse);

    turnoRepository.esperaCancelacion!.complete();
    expect(await cancelacion, isTrue);
    expect(viewModel.estaCancelandoTurno(primero), isFalse);
  });

  test('cancelar quita el turno, su recordatorio y publica el evento',
      () async {
    await viewModel.cargar();
    final eventos = <EventoDeApp>[];
    busDeEventos.eventos.listen(eventos.add);

    await viewModel.cancelar(viewModel.turnos.first);
    await pumpEventQueue();

    expect(viewModel.turnos.map((turno) => turno.id), [2]);
    expect(recordatorioRepository.cancelados, [1]);
    expect(eventos.single, isA<TurnoCanceladoEvento>());
  });

  test('recarga la lista cuando se confirma un turno nuevo', () async {
    await viewModel.cargar();
    turnoRepository.turnos.add(crearTurno(3));

    busDeEventos.publicar(
      TurnoConfirmadoEvento(
        especialidad: 'Clínica Médica',
        profesional: 'Dra. Ana López',
        fecha: DateTime(2030),
      ),
    );
    await pumpEventQueue();

    expect(viewModel.turnos, hasLength(3));
  });
}
