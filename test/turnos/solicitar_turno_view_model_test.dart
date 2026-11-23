import 'package:clinica_vitalis/domain/models/borrador_turno.dart';
import 'package:clinica_vitalis/domain/models/evento_de_app.dart';
import 'package:clinica_vitalis/ui/core/bus_de_eventos.dart';
import 'package:clinica_vitalis/ui/turnos/view_models/solicitar_turno_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_borrador_repository.dart';
import '../fakes/fake_perfil_repository.dart';
import '../fakes/fake_recordatorio_repository.dart';
import '../fakes/fake_turno_repository.dart';

void main() {
  late FakeTurnoRepository turnoRepository;
  late FakeBorradorRepository borradorRepository;
  late FakeRecordatorioRepository recordatorioRepository;
  late BusDeEventos busDeEventos;
  late SolicitarTurnoViewModel viewModel;

  final manana = DateTime.now().add(const Duration(days: 1));

  setUp(() {
    turnoRepository = FakeTurnoRepository();
    borradorRepository = FakeBorradorRepository();
    recordatorioRepository = FakeRecordatorioRepository();
    busDeEventos = BusDeEventos();
    viewModel = SolicitarTurnoViewModel(
      turnoRepository: turnoRepository,
      borradorRepository: borradorRepository,
      recordatorioRepository: recordatorioRepository,
      authRepository: FakeAuthRepository(uidActual: 'p1'),
      perfilRepository: FakePerfilRepository(),
      busDeEventos: busDeEventos,
    );
  });

  tearDown(() => busDeEventos.cerrar());

  Future<void> completarFormulario() async {
    await viewModel.cargar();
    viewModel.seleccionarEspecialidad('Clínica Médica');
    await viewModel.seleccionarProfesional('Dra. Ana López');
    await viewModel.seleccionarFecha(manana);
    viewModel.seleccionarHorario('09:00');
  }

  test('confirmar sin completar los datos devuelve null y un error', () async {
    await viewModel.cargar();

    expect(await viewModel.confirmar(), isNull);
    expect(viewModel.error, isNotNull);
  });

  test('confirmar guarda, programa el recordatorio y publica el evento',
      () async {
    await completarFormulario();
    final eventos = <EventoDeApp>[];
    busDeEventos.eventos.listen(eventos.add);

    final turno = await viewModel.confirmar();
    await pumpEventQueue();

    expect(turno?.id, isNotNull);
    expect(recordatorioRepository.programados.single.id, turno!.id);
    expect(borradorRepository.borradorTurno.estaVacio, isTrue);
    expect(eventos.single, isA<TurnoConfirmadoEvento>());
    expect(viewModel.especialidadSeleccionada, isNull);
  });

  test('si el horario se ocupa, informa el error y no programa nada', () async {
    await completarFormulario();
    turnoRepository.horarioOcupado = true;

    expect(await viewModel.confirmar(), isNull);
    expect(viewModel.error, contains('ocupar'));
    expect(viewModel.horarioSeleccionado, isNull);
    expect(recordatorioRepository.programados, isEmpty);
  });

  test('restaura el borrador pero descarta una fecha que ya paso', () async {
    borradorRepository.borradorTurno = BorradorTurno(
      especialidad: 'Clínica Médica',
      profesional: 'Dra. Ana López',
      fecha: DateTime(2020),
      horario: '09:00',
    );

    await viewModel.cargar();

    expect(viewModel.especialidadSeleccionada, 'Clínica Médica');
    expect(viewModel.profesionalSeleccionado, 'Dra. Ana López');
    expect(viewModel.fechaSeleccionada, isNull);
    expect(viewModel.horarioSeleccionado, isNull);
  });
}
