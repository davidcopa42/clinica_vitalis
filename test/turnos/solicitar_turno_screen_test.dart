import 'package:clinica_vitalis/data/repositories/borrador_repository.dart';
import 'package:clinica_vitalis/data/services/bus_de_eventos.dart';
import 'package:clinica_vitalis/domain/models/borrador_sintomas.dart';
import 'package:clinica_vitalis/domain/models/borrador_turno.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/profesional.dart';
import 'package:clinica_vitalis/ui/turnos/view_models/turno_view_model.dart';
import 'package:clinica_vitalis/ui/turnos/widgets/solicitar_turno_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_recordatorio_repository.dart';
import '../fakes/fake_turno_repository.dart';

/// Borrador de turno fijo, configurable desde el test.
class FakeBorradorRepository implements BorradorRepository {
  FakeBorradorRepository([this.borrador = const BorradorTurno()]);

  final BorradorTurno borrador;

  @override
  Future<BorradorTurno> obtenerBorradorTurno() async => borrador;

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

const paciente = Paciente(
  uid: 'paciente-1',
  nombre: 'Ana',
  apellido: 'López',
  correo: 'ana@test.com',
);

const profesionales = [
  Profesional(
    nombre: 'Dr. Juan Pérez',
    especialidad: 'Cardiología',
    horarios: ['08:00', '08:40'],
  ),
];

void main() {
  final fecha = DateTime(2030, 3, 15);

  Future<void> mostrarFormulario(
    WidgetTester tester, {
    BorradorTurno borrador = const BorradorTurno(),
    List<String> horarios = const ['08:00', '08:40'],
  }) async {
    final busDeEventos = BusDeEventos();
    addTearDown(busDeEventos.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: SolicitarTurnoScreen(
          paciente: paciente,
          viewModel: TurnoViewModel(
            repositorio: FakeTurnoRepository(
              profesionales: profesionales,
              horarios: horarios,
            ),
            borradorRepository: FakeBorradorRepository(borrador),
            recordatorioRepository: FakeRecordatorioRepository(),
            busDeEventos: busDeEventos,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  BorradorTurno borradorCompleto({String? horario}) => BorradorTurno(
        especialidad: 'Cardiología',
        profesional: 'Dr. Juan Pérez',
        fecha: fecha,
        horario: horario,
      );

  testWidgets('sin borrador pide elegir fecha y el profesional esta bloqueado',
      (tester) async {
    await mostrarFormulario(tester);

    expect(find.text('Seleccionar fecha'), findsOneWidget);
    final profesional = tester.widget<DropdownButton<String>>(
      find.byType(DropdownButton<String>).at(1),
    );
    expect(profesional.onChanged, isNull);
  });

  testWidgets('confirmar sin datos muestra el error', (tester) async {
    await mostrarFormulario(tester);

    await tester.tap(find.text('Confirmar turno'));
    await tester.pumpAndSettle();

    expect(find.text('Completá todos los datos del turno.'), findsOneWidget);
  });

  testWidgets('con borrador muestra la fecha formateada y el horario',
      (tester) async {
    await mostrarFormulario(tester,
        borrador: borradorCompleto(horario: '08:40'));

    expect(find.text('15/03/2030'), findsOneWidget);
    expect(find.text('Cardiología'), findsOneWidget);
    expect(find.text('Dr. Juan Pérez'), findsOneWidget);
    expect(find.text('08:40'), findsOneWidget);
    expect(find.text('No hay horarios libres ese día.'), findsNothing);
  });

  testWidgets('sin horarios libres lo avisa debajo del campo', (tester) async {
    await mostrarFormulario(
      tester,
      borrador: borradorCompleto(),
      horarios: const [],
    );

    expect(find.text('No hay horarios libres ese día.'), findsOneWidget);
  });
}
