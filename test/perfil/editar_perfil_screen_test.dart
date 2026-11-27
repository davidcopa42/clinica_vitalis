import 'package:clinica_vitalis/data/repositories/perfil_repository.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/ui/perfil/view_models/perfil_view_model.dart';
import 'package:clinica_vitalis/ui/perfil/widgets/editar_perfil_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_repository.dart';

/// Repositorio de perfil falso que registra lo guardado.
class FakePerfilRepository implements PerfilRepository {
  Map<String, dynamic>? guardado;

  @override
  Future<void> guardarPerfil(
    String uid,
    Map<String, dynamic> datosPerfil,
  ) async {
    guardado = datosPerfil;
  }

  @override
  Future<Paciente?> obtenerPerfil(String uid) async =>
      guardado == null ? null : Paciente.fromMap(guardado!);

  @override
  Future<Map<String, dynamic>?> cargarPerfilUsuario(String uid) async =>
      guardado;
}

final pacienteOriginal = Paciente(
  uid: 'uid-1',
  nombre: 'Ana',
  apellido: 'López',
  correo: 'ana@test.com',
  telefono: '2615551234',
  dni: '30111222',
  fechaNacimiento: DateTime(1990, 5, 12),
  obraSocial: 'OSDE',
  numeroAfiliado: '9876',
);

void main() {
  late FakePerfilRepository perfiles;
  late PerfilViewModel viewModel;

  Future<void> abrirEdicion(WidgetTester tester, Paciente paciente) async {
    perfiles = FakePerfilRepository();
    viewModel = PerfilViewModel(
      repository: perfiles,
      authRepository: FakeAuthRepository(),
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditarPerfilScreen(
                    uid: 'uid-1',
                    paciente: paciente,
                    viewModel: viewModel,
                  ),
                ),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
  }

  Future<void> guardar(WidgetTester tester) async {
    final boton = find.text('Guardar Cambios');
    await tester.ensureVisible(boton);
    await tester.tap(boton);
    await tester.pumpAndSettle();
  }

  testWidgets('precarga los campos con los datos del paciente', (tester) async {
    await abrirEdicion(tester, pacienteOriginal);

    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('López'), findsOneWidget);
    expect(find.text('30111222'), findsOneWidget);
    expect(find.text('12/05/1990'), findsOneWidget);
    expect(find.text('2615551234'), findsOneWidget);
    expect(find.text('9876'), findsOneWidget);
  });

  testWidgets('guarda lo editado y conserva la fecha si no se cambio',
      (tester) async {
    await abrirEdicion(tester, pacienteOriginal);

    await tester.enterText(find.text('2615551234'), '2617778888');
    await guardar(tester);

    final guardado = Paciente.fromMap(perfiles.guardado!);
    expect(guardado.telefono, '2617778888');
    expect(guardado.nombre, 'Ana');
    expect(guardado.fechaNacimiento, DateTime(1990, 5, 12));
    expect(guardado.obraSocial, 'OSDE');
    expect(guardado.numeroAfiliado, '9876');
    expect(guardado.correo, 'ana@test.com');
    expect(find.text('Perfil actualizado correctamente'), findsOneWidget);
  });

  testWidgets('con Particular guarda el numero de afiliado vacio',
      (tester) async {
    await abrirEdicion(
      tester,
      pacienteOriginal.copyWith(obraSocial: 'Particular'),
    );

    await guardar(tester);

    expect(perfiles.guardado!['obraSocial'], 'Particular');
    expect(perfiles.guardado!['numeroAfiliado'], '');
  });

  testWidgets('una obra social desconocida se muestra como Particular',
      (tester) async {
    await abrirEdicion(
      tester,
      pacienteOriginal.copyWith(obraSocial: 'Obra que ya no existe'),
    );

    await guardar(tester);

    expect(perfiles.guardado!['obraSocial'], 'Particular');
  });
}
