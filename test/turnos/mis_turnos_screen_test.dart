import 'dart:async';

import 'package:clinica_vitalis/data/services/bus_de_eventos.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:clinica_vitalis/ui/turnos/view_models/mis_turnos_view_model.dart';
import 'package:clinica_vitalis/ui/turnos/widgets/mis_turnos_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_recordatorio_repository.dart';
import '../fakes/fake_turno_repository.dart';

const paciente = Paciente(
  uid: 'paciente-1',
  nombre: 'Ana',
  apellido: 'López',
  correo: 'ana@test.com',
);

Turno crearTurno(int id, String horario) {
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

  setUp(() {
    busDeEventos = BusDeEventos();
    repositorio = FakeTurnoRepository(
      turnos: [crearTurno(1, '08:00'), crearTurno(2, '08:40')],
    );
  });

  tearDown(() => busDeEventos.dispose());

  Future<void> mostrarPantalla(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: MisTurnosScreen(
          paciente: paciente,
          viewModel: MisTurnosViewModel(
            repositorio: repositorio,
            recordatorioRepository: FakeRecordatorioRepository(),
            busDeEventos: busDeEventos,
            pacienteUid: paciente.uid,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('al cancelar un turno solo su tarjeta muestra el spinner',
      (tester) async {
    await mostrarPantalla(tester);
    final bloqueo = Completer<void>();
    repositorio.bloqueoAlCancelar = bloqueo;

    await tester
        .tap(find.widgetWithText(OutlinedButton, 'Cancelar turno').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Cancelar turno'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final botones = tester
        .widgetList<OutlinedButton>(find.byType(OutlinedButton))
        .map((boton) => boton.onPressed != null);
    expect(botones, [false, true]);

    bloqueo.complete();
    await tester.pumpAndSettle();
  });
}
