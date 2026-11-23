import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/ui/conectividad/view_models/conectividad_view_model.dart';
import 'package:clinica_vitalis/ui/historia_clinica/widgets/historia_clinica_screen.dart';
import 'package:clinica_vitalis/ui/informacion/widgets/informacion_screen.dart';
import 'package:clinica_vitalis/ui/inicio/view_models/inicio_view_model.dart';
import 'package:clinica_vitalis/ui/inicio/widgets/inicio_screen.dart';
import 'package:clinica_vitalis/ui/perfil/view_models/perfil_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/dependencias_falsas.dart';

const pacienteAna = Paciente(
  uid: 'uid-1',
  nombre: 'Ana',
  apellido: 'López',
  correo: 'ana@test.com',
);

void main() {
  Future<void> mostrarInicio(WidgetTester tester, Paciente paciente) async {
    // Superficie alta: el ListView no construye las tarjetas fuera de
    // pantalla y en 800x600 la ultima queda afuera.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final dependencias = crearDependenciasFalsas();
    final inicio = InicioViewModel(
      busDeEventos: dependencias.busDeEventos,
      authRepository: dependencias.authRepository,
      paciente: paciente,
    );
    final perfil = PerfilViewModel(
      repository: dependencias.perfilRepository,
      authRepository: dependencias.authRepository,
    );
    final conectividad = ConectividadViewModel(
      repositorio: dependencias.conectividadRepository,
    );
    addTearDown(() {
      inicio.dispose();
      perfil.dispose();
      conectividad.dispose();
      dependencias.busDeEventos.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: InicioScreen(
          paciente: paciente,
          dependencias: dependencias,
          inicioViewModel: inicio,
          perfilViewModel: perfil,
          conectividadViewModel: conectividad,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('saluda al paciente y ofrece las cuatro acciones',
      (tester) async {
    await mostrarInicio(tester, pacienteAna);

    expect(find.text('Hola, Ana'), findsOneWidget);
    expect(find.text('Solicitar un turno'), findsOneWidget);
    expect(find.text('Mis turnos'), findsOneWidget);
    expect(find.text('Registrar síntomas'), findsOneWidget);
    expect(find.text('Historia clínica'), findsOneWidget);
  });

  testWidgets('sin nombre saluda como Paciente', (tester) async {
    await mostrarInicio(tester, pacienteAna.copyWith(nombre: ''));

    expect(find.text('Hola, Paciente'), findsOneWidget);
  });

  testWidgets('la tarjeta de Historia clinica abre esa pantalla',
      (tester) async {
    await mostrarInicio(tester, pacienteAna);

    await tester.tap(find.text('Historia clínica'));
    await tester.pumpAndSettle();

    expect(find.byType(HistoriaClinicaScreen), findsOneWidget);
  });

  testWidgets('la pestana Informacion muestra InformacionScreen',
      (tester) async {
    await mostrarInicio(tester, pacienteAna);

    await tester.tap(find.text('Información'));
    await tester.pumpAndSettle();

    expect(find.byType(InformacionScreen), findsOneWidget);
  });

  testWidgets('el avatar sin uid avisa que no hay usuario identificado',
      (tester) async {
    await mostrarInicio(tester, pacienteAna.copyWith(uid: ''));

    await tester.tap(find.byType(CircleAvatar));
    await tester.pumpAndSettle();

    expect(find.text('Error: Usuario no identificado'), findsOneWidget);
  });
}
