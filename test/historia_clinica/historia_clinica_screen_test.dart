import 'package:clinica_vitalis/data/repositories/historia_clinica_repository.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/registro_clinico.dart';
import 'package:clinica_vitalis/ui/historia_clinica/view_models/historia_clinica_view_model.dart';
import 'package:clinica_vitalis/ui/historia_clinica/widgets/historia_clinica_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeHistoriaClinicaRepository implements HistoriaClinicaRepository {
  FakeHistoriaClinicaRepository(this.registros);

  final List<RegistroClinico> registros;

  @override
  Future<List<RegistroClinico>> obtenerRegistros(String pacienteUid) async =>
      registros;
}

const paciente = Paciente(
  uid: 'uid-1',
  nombre: 'Ana',
  apellido: 'López',
  correo: 'ana@test.com',
);

final registros = [
  RegistroClinico(
    tipo: TipoRegistro.analisis,
    titulo: 'Hemograma completo',
    fecha: DateTime(2026, 10, 20),
    profesional: 'Dra. Laura Pérez',
    detalle: 'Análisis de sangre de rutina.',
  ),
  RegistroClinico(
    tipo: TipoRegistro.receta,
    titulo: 'Receta médica',
    fecha: DateTime(2026, 9, 5),
    profesional: 'Dra. Ana Torres',
    detalle: 'Registro de receta.',
  ),
];

void main() {
  Future<void> mostrarHistoria(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HistoriaClinicaScreen(
          paciente: paciente,
          viewModel: HistoriaClinicaViewModel(
            repositorio: FakeHistoriaClinicaRepository(registros),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lista los registros con profesional y fecha', (tester) async {
    await mostrarHistoria(tester);

    expect(find.text('Hemograma completo'), findsOneWidget);
    expect(find.text('Dra. Laura Pérez\n20/10/2026'), findsOneWidget);
    expect(find.text('Receta médica'), findsOneWidget);
    expect(find.text('Dra. Ana Torres\n5/9/2026'), findsOneWidget);
    expect(find.byIcon(Icons.science), findsOneWidget);
    expect(find.byIcon(Icons.description), findsOneWidget);
  });

  testWidgets('el filtro muestra solo el tipo elegido', (tester) async {
    await mostrarHistoria(tester);

    await tester.tap(find.text('Recetas'));
    await tester.pumpAndSettle();

    expect(find.text('Receta médica'), findsOneWidget);
    expect(find.text('Hemograma completo'), findsNothing);

    await tester.tap(find.text('Estudios'));
    await tester.pumpAndSettle();

    expect(find.text('No hay registros para este filtro.'), findsOneWidget);
  });

  testWidgets('al tocar un registro abre su detalle', (tester) async {
    await mostrarHistoria(tester);

    await tester.tap(find.text('Receta médica'));
    await tester.pumpAndSettle();

    expect(find.text('Detalle del registro'), findsOneWidget);
    expect(find.text('Receta'), findsOneWidget);
    expect(find.text('5/9/2026'), findsOneWidget);
    expect(find.text('Dra. Ana Torres'), findsOneWidget);
    expect(find.text('Registro de receta.'), findsOneWidget);
  });
}
