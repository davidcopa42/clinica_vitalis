import 'package:clinica_vitalis/data/repositories/borrador_repository.dart';
import 'package:clinica_vitalis/domain/models/borrador_sintomas.dart';
import 'package:clinica_vitalis/domain/models/borrador_turno.dart';
import 'package:clinica_vitalis/ui/sintomas/view_models/sintomas_view_model.dart';
import 'package:clinica_vitalis/ui/sintomas/widgets/sintomas_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Borrador en memoria: siempre arranca vacío.
class FakeBorradorRepository implements BorradorRepository {
  @override
  Future<BorradorSintomas> obtenerBorradorSintomas() async =>
      const BorradorSintomas();

  @override
  Future<void> guardarBorradorSintomas(BorradorSintomas borrador) async {}

  @override
  Future<void> borrarBorradorSintomas() async {}

  @override
  Future<BorradorTurno> obtenerBorradorTurno() async => const BorradorTurno();

  @override
  Future<void> guardarBorradorTurno(BorradorTurno borrador) async {}

  @override
  Future<void> borrarBorradorTurno() async {}
}

void main() {
  late int turnosSolicitados;

  Future<void> mostrarSintomas(WidgetTester tester) async {
    turnosSolicitados = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: SintomasScreen(
          viewModel: SintomasViewModel(
            borradorRepository: FakeBorradorRepository(),
          ),
          onSolicitarTurno: () => turnosSolicitados++,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, String texto) async {
    final objetivo = find.text(texto);
    await tester.ensureVisible(objetivo);
    await tester.tap(objetivo);
    await tester.pumpAndSettle();
  }

  testWidgets('muestra los sintomas, la intensidad inicial y el boton de turno',
      (tester) async {
    await mostrarSintomas(tester);

    expect(find.byType(FilterChip), findsNWidgets(13));
    expect(find.text('Intensidad: 1 / 10'), findsOneWidget);
    expect(find.text('Solicitar turno'), findsOneWidget);
    expect(find.text('Acudí a la guardia ahora o llamá al 107.'), findsNothing);
  });

  testWidgets('un sintoma de alarma muestra el aviso y oculta Solicitar turno',
      (tester) async {
    await mostrarSintomas(tester);

    await tocar(tester, 'Dolor de pecho');

    expect(
      find.text('Acudí a la guardia ahora o llamá al 107.'),
      findsOneWidget,
    );
    expect(find.text('Solicitar turno'), findsNothing);
  });

  testWidgets('al registrar sin alarma recomienda solicitar un turno',
      (tester) async {
    await mostrarSintomas(tester);

    await tocar(tester, 'Fiebre');
    await tocar(tester, 'Registrar síntomas');

    expect(
      find.text('La información quedó registrada en esta sesión. '
          'Te recomendamos solicitar un turno.'),
      findsOneWidget,
    );

    await tocar(tester, 'Solicitar turno');
    expect(turnosSolicitados, 1);
  });

  testWidgets('al registrar con alarma solo confirma el registro',
      (tester) async {
    await mostrarSintomas(tester);

    await tocar(tester, 'Falta de aire');
    await tocar(tester, 'Registrar síntomas');

    expect(
      find.text('La información quedó registrada en esta sesión.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Te recomendamos solicitar un turno.'),
      findsNothing,
    );
  });
}
