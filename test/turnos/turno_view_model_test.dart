import 'dart:async';

import 'package:clinica_vitalis/data/repositories/borrador_repositorio_local.dart';
import 'package:clinica_vitalis/data/repositories/turno_repository.dart';
import 'package:clinica_vitalis/data/services/borrador_service.dart';
import 'package:clinica_vitalis/data/services/bus_de_eventos.dart';
import 'package:clinica_vitalis/domain/models/evento_de_app.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/profesional.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';
import 'package:clinica_vitalis/ui/turnos/view_models/turno_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_recordatorio_repository.dart';
import '../fakes/fake_turno_repository.dart';

const profesionales = [
  Profesional(
    nombre: 'Dra. Ana López',
    especialidad: 'Clínica Médica',
    horarios: ['09:00', '09:30'],
  ),
  Profesional(
    nombre: 'Dr. Roberto Díaz',
    especialidad: 'Clínica Médica',
    horarios: ['14:00'],
  ),
  Profesional(
    nombre: 'Dr. Juan Pérez',
    especialidad: 'Cardiología',
    horarios: ['08:00', '08:40'],
  ),
];

const paciente = Paciente(
  uid: 'paciente-1',
  nombre: 'Ana',
  apellido: 'Gómez',
  correo: 'ana@test.com',
);

const clavesBorrador = [
  'borrador_especialidad',
  'borrador_profesional',
  'borrador_fecha',
  'borrador_horario',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fecha = DateTime(2030, 3, 15);

  late BusDeEventos busDeEventos;
  late FakeTurnoRepository repositorio;
  late FakeRecordatorioRepository recordatorios;
  late TurnoViewModel viewModel;
  late List<EventoDeApp> eventosPublicados;
  late StreamSubscription<EventoDeApp> suscripcion;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    recordatorios = FakeRecordatorioRepository();
    repositorio = FakeTurnoRepository(
      profesionales: profesionales,
      horarios: ['08:00', '08:40'],
    );
    busDeEventos = BusDeEventos();
    viewModel = TurnoViewModel(
      repositorio: repositorio,
      borradorRepository:
          BorradorRepositorioLocal(borradorService: BorradorService()),
      recordatorioRepository: recordatorios,
      busDeEventos: busDeEventos,
    );
    eventosPublicados = [];
    suscripcion = busDeEventos.stream.listen(eventosPublicados.add);
  });

  tearDown(() async {
    await suscripcion.cancel();
    viewModel.dispose();
    busDeEventos.dispose();
  });

  /// Deja el formulario completo: Cardiología, Dr. Juan Pérez, fecha y 08:40.
  Future<void> completarFormulario() async {
    await viewModel.cargar();
    viewModel.seleccionarEspecialidad('Cardiología');
    await viewModel.seleccionarProfesional('Dr. Juan Pérez');
    await viewModel.seleccionarFecha(fecha);
    viewModel.seleccionarHorario('08:40');
    await pumpEventQueue();
  }

  group('cargar', () {
    test('sin borrador queda en exito con especialidades sin repetir',
        () async {
      await viewModel.cargar();

      expect(viewModel.estado, EstadoCarga.exito);
      expect(viewModel.especialidades, ['Clínica Médica', 'Cardiología']);
      expect(viewModel.especialidadSeleccionada, isNull);
      expect(viewModel.profesionalSeleccionado, isNull);
      expect(viewModel.fechaSeleccionada, isNull);
      expect(viewModel.horarioSeleccionado, isNull);
    });

    test('si el repositorio falla queda en error', () async {
      repositorio.errorAlObtenerProfesionales = Exception('sin datos');

      await viewModel.cargar();

      expect(viewModel.estado, EstadoCarga.error);
    });

    test('restaura un borrador completo y valido', () async {
      SharedPreferences.setMockInitialValues({
        'borrador_especialidad': 'Cardiología',
        'borrador_profesional': 'Dr. Juan Pérez',
        'borrador_fecha': fecha.toIso8601String(),
        'borrador_horario': '08:40',
      });

      await viewModel.cargar();

      expect(viewModel.especialidadSeleccionada, 'Cardiología');
      expect(viewModel.profesionalSeleccionado, 'Dr. Juan Pérez');
      expect(viewModel.fechaSeleccionada, fecha);
      expect(viewModel.horariosDisponibles, ['08:00', '08:40']);
      expect(viewModel.horarioSeleccionado, '08:40');
    });

    test('descarta el horario del borrador si ya no esta disponible', () async {
      SharedPreferences.setMockInitialValues({
        'borrador_especialidad': 'Cardiología',
        'borrador_profesional': 'Dr. Juan Pérez',
        'borrador_fecha': fecha.toIso8601String(),
        'borrador_horario': '10:00',
      });

      await viewModel.cargar();

      expect(viewModel.profesionalSeleccionado, 'Dr. Juan Pérez');
      expect(viewModel.horarioSeleccionado, isNull);
    });

    test('ignora todo el borrador si la especialidad no existe', () async {
      SharedPreferences.setMockInitialValues({
        'borrador_especialidad': 'Neurología',
        'borrador_profesional': 'Dr. Juan Pérez',
        'borrador_fecha': fecha.toIso8601String(),
      });

      await viewModel.cargar();

      expect(viewModel.especialidadSeleccionada, isNull);
      expect(viewModel.profesionalSeleccionado, isNull);
      expect(viewModel.fechaSeleccionada, isNull);
    });

    test(
        'ignora profesional y fecha si el profesional no es de la especialidad',
        () async {
      SharedPreferences.setMockInitialValues({
        'borrador_especialidad': 'Clínica Médica',
        'borrador_profesional': 'Dr. Juan Pérez',
        'borrador_fecha': fecha.toIso8601String(),
      });

      await viewModel.cargar();

      expect(viewModel.especialidadSeleccionada, 'Clínica Médica');
      expect(viewModel.profesionalSeleccionado, isNull);
      expect(viewModel.fechaSeleccionada, isNull);
    });
  });

  group('selecciones', () {
    test('elegir especialidad filtra profesionales y limpia lo posterior',
        () async {
      await completarFormulario();

      viewModel.seleccionarEspecialidad('Clínica Médica');

      expect(
        viewModel.profesionalesDisponibles.map((p) => p.nombre),
        ['Dra. Ana López', 'Dr. Roberto Díaz'],
      );
      expect(viewModel.profesionalSeleccionado, isNull);
      expect(viewModel.horarioSeleccionado, isNull);
      expect(viewModel.horariosDisponibles, isEmpty);
      expect(viewModel.fechaSeleccionada, fecha);
    });

    test('con profesional y fecha pide los horarios al repositorio', () async {
      await viewModel.cargar();
      viewModel.seleccionarEspecialidad('Cardiología');
      await viewModel.seleccionarProfesional('Dr. Juan Pérez');

      expect(viewModel.puedeElegirHorario, isFalse);
      expect(repositorio.consultasDeHorarios, isEmpty);

      await viewModel.seleccionarFecha(fecha);

      expect(repositorio.consultasDeHorarios, [('Dr. Juan Pérez', fecha)]);
      expect(viewModel.horariosDisponibles, ['08:00', '08:40']);
      expect(viewModel.puedeElegirHorario, isTrue);
      expect(viewModel.cargandoHorarios, isFalse);
    });

    test('si fallan los horarios queda la lista vacia y un error', () async {
      repositorio.errorAlObtenerHorarios = Exception('falla');
      await viewModel.cargar();
      viewModel.seleccionarEspecialidad('Cardiología');
      await viewModel.seleccionarProfesional('Dr. Juan Pérez');
      await viewModel.seleccionarFecha(fecha);

      expect(viewModel.horariosDisponibles, isEmpty);
      expect(viewModel.error, 'No se pudieron cargar los horarios.');
    });

    test('cada seleccion guarda el borrador en SharedPreferences', () async {
      await completarFormulario();

      final preferencias = await SharedPreferences.getInstance();
      expect(preferencias.getString('borrador_especialidad'), 'Cardiología');
      expect(preferencias.getString('borrador_profesional'), 'Dr. Juan Pérez');
      expect(preferencias.getString('borrador_fecha'), fecha.toIso8601String());
      expect(preferencias.getString('borrador_horario'), '08:40');
    });

    test('horariosDisponibles no se puede modificar desde afuera', () async {
      await completarFormulario();

      expect(
        () => viewModel.horariosDisponibles.add('99:99'),
        throwsUnsupportedError,
      );
    });
  });

  group('confirmar', () {
    test('con datos incompletos no llama al repositorio y marca error',
        () async {
      await viewModel.cargar();

      final turno = await viewModel.confirmar(paciente);

      expect(turno, isNull);
      expect(viewModel.error, 'Completá todos los datos del turno.');
      expect(repositorio.turnosGuardados, isEmpty);
    });

    test('guarda el turno, limpia el borrador y publica el evento', () async {
      await completarFormulario();

      final turno = await viewModel.confirmar(paciente);
      await pumpEventQueue();

      expect(turno, isNotNull);
      expect(turno!.id, 100);
      final enviado = repositorio.turnosGuardados.single;
      expect(enviado.pacienteUid, 'paciente-1');
      expect(enviado.especialidad, 'Cardiología');
      expect(enviado.profesional, 'Dr. Juan Pérez');
      expect(enviado.fecha, fecha);
      expect(enviado.horario, '08:40');
      expect(viewModel.guardando, isFalse);
      expect(viewModel.error, isNull);

      final preferencias = await SharedPreferences.getInstance();
      for (final clave in clavesBorrador) {
        expect(preferencias.containsKey(clave), isFalse, reason: clave);
      }

      final evento = eventosPublicados.single as TurnoConfirmadoEvento;
      expect(evento.especialidad, 'Cardiología');
      expect(evento.profesional, 'Dr. Juan Pérez');
      expect(evento.fecha, fecha);
    });

    test('si el horario se ocupo limpia el horario y recarga los horarios',
        () async {
      await completarFormulario();
      repositorio.errorAlGuardar = const TurnoNoDisponibleException();
      final consultasPrevias = repositorio.consultasDeHorarios.length;

      final turno = await viewModel.confirmar(paciente);

      expect(turno, isNull);
      expect(viewModel.error, 'Ese horario se acaba de ocupar. Elegí otro.');
      expect(viewModel.horarioSeleccionado, isNull);
      expect(repositorio.consultasDeHorarios.length, consultasPrevias + 1);
      expect(viewModel.guardando, isFalse);
      expect(eventosPublicados, isEmpty);
    });

    test('ante un error inesperado devuelve null y conserva el borrador',
        () async {
      await completarFormulario();
      repositorio.errorAlGuardar = Exception('disco lleno');

      final turno = await viewModel.confirmar(paciente);

      expect(turno, isNull);
      expect(viewModel.error, 'No se pudo guardar el turno. Probá de nuevo.');
      expect(viewModel.guardando, isFalse);
      expect(viewModel.horarioSeleccionado, '08:40');
      final preferencias = await SharedPreferences.getInstance();
      expect(preferencias.getString('borrador_horario'), '08:40');
      expect(eventosPublicados, isEmpty);
    });
  });

  group('recordatorio', () {
    test('al confirmar programa el recordatorio del turno guardado', () async {
      await completarFormulario();

      final turno = await viewModel.confirmar(paciente);

      expect(recordatorios.turnosProgramados.single.id, turno!.id);
      expect(recordatorios.turnosProgramados.single.horario, '08:40');
    });

    test('si no se guarda el turno no se programa recordatorio', () async {
      await viewModel.cargar();
      await viewModel.confirmar(paciente);

      await completarFormulario();
      repositorio.errorAlGuardar = const TurnoNoDisponibleException();
      await viewModel.confirmar(paciente);

      repositorio.errorAlGuardar = Exception('disco lleno');
      viewModel.seleccionarHorario('08:00');
      await viewModel.confirmar(paciente);

      expect(recordatorios.turnosProgramados, isEmpty);
    });

    test(
        'si falla el recordatorio el error se propaga, pero el turno ya '
        'quedo guardado, sin borrador y con el evento publicado', () async {
      await completarFormulario();
      recordatorios.errorAlProgramar = Exception('sin permiso');

      await expectLater(viewModel.confirmar(paciente), throwsException);
      await pumpEventQueue();

      expect(repositorio.turnosGuardados, hasLength(1));
      expect(viewModel.guardando, isFalse);
      expect(viewModel.error, isNull);
      final preferencias = await SharedPreferences.getInstance();
      expect(preferencias.containsKey('borrador_horario'), isFalse);
      expect(eventosPublicados, hasLength(1));
    });
  });
}
