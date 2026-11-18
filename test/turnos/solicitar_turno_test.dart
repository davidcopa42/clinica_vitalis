import 'package:clinica_vitalis/data/repositories/turno_repository.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/ui/turnos/widgets/solicitar_turno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base_datos_service_falso.dart';

/// Muestra la pantalla Solicitar turno con un ancho de pantalla dado.
Future<void> mostrarConAncho(WidgetTester tester, double ancho) async {
  tester.view.physicalSize = Size(ancho, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: TurnoPage(
        paciente: const Paciente(
          uid: 'paciente-de-prueba',
          nombre: 'Ana',
          apellido: 'Pérez',
          correo: 'ana@ejemplo.com',
          telefono: '1122334455',
        ),
        repositorio: TurnoRepository(baseDatos: BaseDatosServiceFalso()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Posición del campo Especialidad (el primer desplegable).
Offset posicionEspecialidad(WidgetTester tester) {
  return tester.getTopLeft(find.byType(DropdownButtonFormField<String>).first);
}

/// Posición del botón para elegir la fecha.
Offset posicionFecha(WidgetTester tester) {
  return tester.getTopLeft(find.byType(OutlinedButton));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('en celular muestra los campos en una sola columna',
      (tester) async {
    await mostrarConAncho(tester, 400);

    final especialidad = posicionEspecialidad(tester);
    final fecha = posicionFecha(tester);

    // Misma columna: alineados a la izquierda, Fecha más abajo.
    expect(fecha.dx, especialidad.dx);
    expect(fecha.dy, greaterThan(especialidad.dy));
    expect(find.text('¿Con quién?'), findsNothing);
  });

  testWidgets('en tablet muestra los campos en dos columnas', (tester) async {
    await mostrarConAncho(tester, 900);

    final especialidad = posicionEspecialidad(tester);
    final fecha = posicionFecha(tester);

    // Fecha queda en la columna de la derecha.
    expect(fecha.dx, greaterThan(especialidad.dx + 200));
    expect(find.text('¿Con quién?'), findsOneWidget);
    expect(find.text('¿Cuándo?'), findsOneWidget);
    expect(find.text('Confirmar turno'), findsOneWidget);
  });
}
