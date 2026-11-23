import 'package:clinica_vitalis/data/services/bus_de_eventos.dart';
import 'package:clinica_vitalis/domain/models/evento_de_app.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/ui/inicio/view_models/inicio_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

const paciente = Paciente(
  uid: 'uid-1',
  nombre: 'Ana',
  apellido: 'López',
  correo: 'ana@test.com',
);

void main() {
  late BusDeEventos busDeEventos;
  late InicioViewModel viewModel;
  var viewModelDescartado = false;

  setUp(() {
    busDeEventos = BusDeEventos();
    viewModel = InicioViewModel(busDeEventos: busDeEventos, paciente: paciente);
    viewModelDescartado = false;
  });

  tearDown(() {
    if (!viewModelDescartado) viewModel.dispose();
    busDeEventos.dispose();
  });

  void publicarTurnoConfirmado() {
    busDeEventos.publicar(
      TurnoConfirmadoEvento(
        especialidad: 'Cardiología',
        profesional: 'Dr. Juan Pérez',
        fecha: DateTime(2030, 3, 15),
      ),
    );
  }

  group('nombreUsuario', () {
    test('usa el nombre del paciente', () {
      expect(viewModel.nombreUsuario, 'Ana');
    });

    test('sin nombre saluda como Paciente', () {
      final sinNombre = InicioViewModel(
        busDeEventos: busDeEventos,
        paciente: paciente.copyWith(nombre: ''),
      );
      addTearDown(sinNombre.dispose);

      expect(sinNombre.nombreUsuario, 'Paciente');
    });
  });

  group('aviso de turno confirmado', () {
    test('al principio no hay aviso', () {
      expect(viewModel.avisoPendiente, isNull);
    });

    test('un turno confirmado deja el aviso y notifica', () async {
      var notificaciones = 0;
      viewModel.addListener(() => notificaciones++);

      publicarTurnoConfirmado();
      await pumpEventQueue();

      expect(
        viewModel.avisoPendiente,
        '¡Éxito! Turno de Cardiología registrado.',
      );
      expect(notificaciones, 1);
    });

    test('descartarAviso lo limpia sin notificar', () async {
      publicarTurnoConfirmado();
      await pumpEventQueue();
      var notificaciones = 0;
      viewModel.addListener(() => notificaciones++);

      viewModel.descartarAviso();

      expect(viewModel.avisoPendiente, isNull);
      expect(notificaciones, 0);
    });

    test('despues de dispose deja de escuchar el bus', () async {
      viewModel.dispose();
      viewModelDescartado = true;

      publicarTurnoConfirmado();
      await pumpEventQueue();

      expect(viewModel.avisoPendiente, isNull);
    });
  });
}
