import 'package:clinica_vitalis/data/services/bus_de_eventos.dart';
import 'package:clinica_vitalis/domain/models/evento_de_app.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/usuario_autenticado.dart';
import 'package:clinica_vitalis/ui/inicio/view_models/inicio_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_recordatorio_repository.dart';

const paciente = Paciente(
  uid: 'uid-1',
  nombre: 'Ana',
  apellido: 'López',
  correo: 'ana@test.com',
);

void main() {
  late BusDeEventos busDeEventos;
  late FakeAuthRepository auth;
  late FakeRecordatorioRepository recordatorios;
  late InicioViewModel viewModel;
  var viewModelDescartado = false;

  setUp(() {
    busDeEventos = BusDeEventos();
    auth = FakeAuthRepository();
    recordatorios = FakeRecordatorioRepository();
    viewModel = InicioViewModel(
      busDeEventos: busDeEventos,
      authRepository: auth,
      recordatorioRepository: recordatorios,
      paciente: paciente,
    );
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

  group('recordatorios tocados', () {
    test('sin recordatorios tocados no abre Mis turnos', () async {
      await pumpEventQueue();

      expect(viewModel.debeAbrirMisTurnos, isFalse);
    });

    test('un recordatorio tocado antes de crearse abre Mis turnos', () async {
      recordatorios.recordatorioTocadoPendiente = true;
      final conRecordatorio = InicioViewModel(
        busDeEventos: busDeEventos,
        authRepository: auth,
        recordatorioRepository: recordatorios,
        paciente: paciente,
      );
      addTearDown(conRecordatorio.dispose);
      await pumpEventQueue();

      expect(conRecordatorio.debeAbrirMisTurnos, isTrue);
      expect(recordatorios.recordatorioTocadoPendiente, isFalse);
    });

    test('un recordatorio tocado con Inicio abierto avisa a la pantalla',
        () async {
      await pumpEventQueue();
      var avisos = 0;
      viewModel.addListener(() => avisos++);

      recordatorios.tocarRecordatorio();
      await pumpEventQueue();

      expect(viewModel.debeAbrirMisTurnos, isTrue);
      expect(avisos, 1);
    });

    test('descartarAperturaMisTurnos lo apaga', () async {
      recordatorios.tocarRecordatorio();
      await pumpEventQueue();

      viewModel.descartarAperturaMisTurnos();

      expect(viewModel.debeAbrirMisTurnos, isFalse);
    });

    test('despues de dispose deja de escuchar los recordatorios', () async {
      viewModel.dispose();
      viewModelDescartado = true;

      recordatorios.tocarRecordatorio();
      await pumpEventQueue();

      expect(recordatorios.recordatorioTocadoPendiente, isTrue);
    });
  });

  group('nombreUsuario', () {
    test('usa el nombre del paciente', () {
      expect(viewModel.nombreUsuario, 'Ana');
    });

    test('sin nombre saluda como Paciente', () {
      final sinNombre = InicioViewModel(
        busDeEventos: busDeEventos,
        authRepository: auth,
        recordatorioRepository: recordatorios,
        paciente: paciente.copyWith(nombre: ''),
      );
      addTearDown(sinNombre.dispose);

      expect(sinNombre.nombreUsuario, 'Paciente');
    });
  });

  group('fotoUrl', () {
    test('usa la foto de la cuenta si tiene', () {
      auth.usuario = const UsuarioAutenticado(
        uid: 'uid-1',
        fotoUrl: 'https://foto.com/cuenta.png',
      );

      expect(viewModel.fotoUrl, 'https://foto.com/cuenta.png');
    });

    test('si la cuenta no tiene foto usa la del perfil del paciente', () {
      final conFotoDePerfil = InicioViewModel(
        busDeEventos: busDeEventos,
        authRepository: auth,
        recordatorioRepository: recordatorios,
        paciente: paciente.copyWith(fotoUrl: 'https://foto.com/perfil.png'),
      );
      addTearDown(conFotoDePerfil.dispose);
      auth.usuario = const UsuarioAutenticado(uid: 'uid-1');

      expect(conFotoDePerfil.fotoUrl, 'https://foto.com/perfil.png');
    });

    test('sin ninguna foto es null', () {
      expect(viewModel.fotoUrl, isNull);
    });
  });

  group('textos y permisos para la pantalla', () {
    test('saludo usa el nombre del paciente', () {
      expect(viewModel.saludo, 'Hola, Ana');
    });

    test('fotoParaMostrar descarta una foto vacia', () {
      auth.usuario = const UsuarioAutenticado(uid: 'uid-1', fotoUrl: '');

      expect(viewModel.fotoParaMostrar, isNull);
    });

    test('fotoParaMostrar devuelve la foto si hay una', () {
      auth.usuario = const UsuarioAutenticado(
        uid: 'uid-1',
        fotoUrl: 'https://foto.com/ana.png',
      );

      expect(viewModel.fotoParaMostrar, 'https://foto.com/ana.png');
    });

    test('puedeAbrirPerfil depende de que el paciente tenga uid', () {
      final sinUid = InicioViewModel(
        busDeEventos: busDeEventos,
        authRepository: auth,
        recordatorioRepository: recordatorios,
        paciente: paciente.copyWith(uid: ''),
      );
      addTearDown(sinUid.dispose);

      expect(viewModel.puedeAbrirPerfil, isTrue);
      expect(sinUid.puedeAbrirPerfil, isFalse);
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
