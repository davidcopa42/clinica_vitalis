import 'package:clinica_vitalis/data/repositories/perfil_repository.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/ui/perfil/view_models/perfil_view_model.dart';
import 'package:clinica_vitalis/ui/perfil/widgets/perfil_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_repository.dart';

class FakePerfilRepository implements PerfilRepository {
  FakePerfilRepository(this.paciente);

  final Paciente? paciente;

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

}

void main() {
  Future<void> mostrarPerfil(WidgetTester tester, Paciente? paciente) async {
    // Pantalla de telefono (360x800): el perfil no tiene scroll y en la
    // superficie por defecto del test (800x600) no entra.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final viewModel = PerfilViewModel(
      repository: FakePerfilRepository(paciente),
      authRepository: FakeAuthRepository(),
    );
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(
      MaterialApp(home: PerfilScreen(uid: 'uid-1', viewModel: viewModel)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('muestra los datos formateados del paciente', (tester) async {
    await mostrarPerfil(
      tester,
      Paciente(
        uid: 'uid-1',
        nombre: 'Ana',
        apellido: 'López',
        correo: 'ana@test.com',
        dni: '30111222',
        telefono: '2615551234',
        fechaNacimiento: DateTime(1990, 5, 12),
        obraSocial: 'OSDE',
        numeroAfiliado: '9876',
      ),
    );

    expect(find.text('Ana López'), findsOneWidget);
    expect(find.text('30111222'), findsOneWidget);
    expect(find.text('12/05/1990'), findsOneWidget);
    expect(find.text('2615551234'), findsOneWidget);
    expect(find.text('OSDE (Nº 9876)'), findsOneWidget);
    expect(find.text('Sin correo electrónico'), findsOneWidget);
  });

  testWidgets('los datos faltantes dicen No registrado', (tester) async {
    await mostrarPerfil(
      tester,
      const Paciente(uid: 'uid-1', nombre: 'Ana', apellido: '', correo: ''),
    );

    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('No registrado'), findsNWidgets(4));
  });

  testWidgets('sin perfil avisa que no hay datos', (tester) async {
    await mostrarPerfil(tester, null);

    expect(find.text('No hay datos de perfil.'), findsOneWidget);
  });
}
