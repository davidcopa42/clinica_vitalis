import 'package:clinica_vitalis/data/repositories/borrador_repository.dart';
import 'package:clinica_vitalis/data/repositories/conectividad_repository.dart';
import 'package:clinica_vitalis/data/repositories/historia_clinica_repository.dart';
import 'package:clinica_vitalis/data/repositories/perfil_repository.dart';
import 'package:clinica_vitalis/data/services/bus_de_eventos.dart';
import 'package:clinica_vitalis/dependencias.dart';
import 'package:clinica_vitalis/domain/models/borrador_sintomas.dart';
import 'package:clinica_vitalis/domain/models/borrador_turno.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/registro_clinico.dart';
import 'package:clinica_vitalis/ui/auth/view_models/sesion_view_model.dart';
import 'package:clinica_vitalis/ui/auth/widgets/login.dart';
import 'package:clinica_vitalis/ui/auth/widgets/puerta_sesion.dart';
import 'package:clinica_vitalis/ui/auth/widgets/verificar_correo.dart';
import 'package:clinica_vitalis/ui/inicio/widgets/inicio.dart';
import 'package:clinica_vitalis/ui/perfil/widgets/completar_perfil_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_recordatorio_repository.dart';
import '../fakes/fake_turno_repository.dart';

/// Perfil configurable: null, incompleto o completo.
class FakePerfilRepository implements PerfilRepository {
  Paciente? paciente;

  @override
  Future<Paciente?> obtenerPerfil(String uid) async => paciente;

  @override
  Future<Map<String, dynamic>?> cargarPerfilUsuario(String uid) async =>
      paciente?.toMap();

  @override
  Future<void> guardarPerfil(
    String uid,
    Map<String, dynamic> datosPerfil,
  ) async {}

  @override
  Future<void> actualizarDatosPerfil(
    String uid, {
    String? nombre,
    String? telefono,
    String? obraSocial,
  }) async {}
}

class FakeHistoriaClinicaRepository implements HistoriaClinicaRepository {
  @override
  Future<List<RegistroClinico>> obtenerRegistros(String pacienteUid) async =>
      [];
}

class FakeBorradorRepository implements BorradorRepository {
  @override
  Future<BorradorTurno> obtenerBorradorTurno() async => const BorradorTurno();

  @override
  Future<void> guardarBorradorTurno(BorradorTurno borrador) async {}

  @override
  Future<void> borrarBorradorTurno() async {}

  @override
  Future<BorradorSintomas> obtenerBorradorSintomas() async =>
      const BorradorSintomas();

  @override
  Future<void> guardarBorradorSintomas(BorradorSintomas borrador) async {}

  @override
  Future<void> borrarBorradorSintomas() async {}
}

class FakeConectividadRepository implements ConectividadRepository {
  @override
  Stream<bool> get cambiosDeConexion => const Stream.empty();

  @override
  Future<bool> verificarConexion() async => true;
}

final pacienteCompleto = Paciente(
  uid: 'uid-1',
  nombre: 'Ana',
  apellido: 'López',
  correo: 'ana@test.com',
  telefono: '261555',
  dni: '30111222',
  fechaNacimiento: DateTime(1990, 5, 12),
);

void main() {
  late FakeAuthRepository auth;
  late FakePerfilRepository perfiles;
  late BusDeEventos busDeEventos;
  late SesionViewModel sesion;

  setUp(() {
    auth = FakeAuthRepository();
    perfiles = FakePerfilRepository();
    busDeEventos = BusDeEventos();
  });

  tearDown(() {
    sesion.dispose();
    busDeEventos.dispose();
  });

  Future<void> montarPuerta(WidgetTester tester) async {
    sesion = SesionViewModel(authRepo: auth, perfilRepo: perfiles);
    final dependencias = Dependencias(
      authRepository: auth,
      perfilRepository: perfiles,
      turnoRepository: FakeTurnoRepository(),
      historiaClinicaRepository: FakeHistoriaClinicaRepository(),
      borradorRepository: FakeBorradorRepository(),
      recordatorioRepository: FakeRecordatorioRepository(),
      conectividadRepository: FakeConectividadRepository(),
      busDeEventos: busDeEventos,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: PuertaSesion(
          sesionViewModel: sesion,
          dependencias: dependencias,
        ),
      ),
    );
    // Sin pumpAndSettle: Verificar correo tiene un indicador animado.
    await tester.pump();
    await tester.pump();
  }

  /// Simula un cambio de sesion y deja que la puerta se acomode.
  Future<void> cambiarSesion(WidgetTester tester, String? uid) async {
    auth.uid = uid;
    auth.controladorSesion.add(uid);
    await tester.pump();
    await tester.pump();
  }

  testWidgets('sin sesion muestra el login', (tester) async {
    await montarPuerta(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('con correo sin verificar muestra Verificar correo',
      (tester) async {
    auth.uid = 'uid-1';
    await montarPuerta(tester);

    expect(find.byType(VerificarCorreoScreen), findsOneWidget);

    // Al cerrar sesion se descarta su ViewModel y se cortan sus timers;
    // si quedaran vivos, el test fallaria por timers pendientes.
    await cambiarSesion(tester, null);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('verificado sin perfil completo muestra Completar perfil',
      (tester) async {
    auth.uid = 'uid-1';
    auth.verificado = true;
    await montarPuerta(tester);

    expect(find.byType(CompletarPerfilScreen), findsOneWidget);
  });

  testWidgets('con perfil completo muestra Inicio con el saludo',
      (tester) async {
    auth.uid = 'uid-1';
    auth.verificado = true;
    perfiles.paciente = pacienteCompleto;
    await montarPuerta(tester);

    expect(find.byType(InicioPage), findsOneWidget);
    expect(find.text('Hola, Ana'), findsOneWidget);
  });

  testWidgets('cada vez que vuelve a una pantalla recibe un ViewModel nuevo',
      (tester) async {
    await montarPuerta(tester);
    final primero =
        tester.widget<LoginScreen>(find.byType(LoginScreen)).viewModel;

    await cambiarSesion(tester, 'uid-1');
    expect(find.byType(VerificarCorreoScreen), findsOneWidget);

    await cambiarSesion(tester, null);
    final segundo =
        tester.widget<LoginScreen>(find.byType(LoginScreen)).viewModel;

    expect(identical(primero, segundo), isFalse);
  });

  testWidgets('mientras no cambia la pantalla conserva el mismo ViewModel',
      (tester) async {
    await montarPuerta(tester);
    final antes =
        tester.widget<LoginScreen>(find.byType(LoginScreen)).viewModel;

    await cambiarSesion(tester, null);
    final despues =
        tester.widget<LoginScreen>(find.byType(LoginScreen)).viewModel;

    expect(identical(antes, despues), isTrue);
  });
}
