import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:clinica_vitalis/ui/turnos/widgets/turno_confirmado_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const paciente = Paciente(
  uid: 'paciente-1',
  nombre: 'Ana',
  apellido: 'López',
  correo: 'ana@test.com',
);

void main() {
  final turno = Turno(
    id: 7,
    pacienteUid: 'paciente-1',
    especialidad: 'Cardiología',
    profesional: 'Dr. Juan Pérez',
    fecha: DateTime(2030, 3, 15),
    horario: '08:40',
  );

  testWidgets('el boton de avisos pide el permiso y muestra la respuesta',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    var pedidos = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: TurnoConfirmadoScreen(
          paciente: paciente,
          turno: turno,
          alActivarAvisos: () async {
            pedidos++;
            return 'Listo, te avisamos un día antes del turno.';
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('15/03/2030'), findsOneWidget);
    await tester.ensureVisible(find.text('Avisarme un día antes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Avisarme un día antes'));
    await tester.pumpAndSettle();

    expect(pedidos, 1);
    expect(
      find.text('Listo, te avisamos un día antes del turno.'),
      findsOneWidget,
    );
  });
}
