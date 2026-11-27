import 'package:clinica_vitalis/ui/core/dialogo_cerrar_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Abre el diálogo y devuelve una función para leer la respuesta.
  Future<bool? Function()> abrirDialogo(WidgetTester tester) async {
    bool? respuesta;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              respuesta = await DialogoCerrarSesion.confirmar(context);
            },
            child: const Text('Abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    return () => respuesta;
  }

  testWidgets('muestra el titulo y la pregunta', (tester) async {
    await abrirDialogo(tester);

    expect(find.text('Cerrar sesión'), findsOneWidget);
    expect(find.text('¿Estás seguro de que deseas salir?'), findsOneWidget);
  });

  testWidgets('Salir confirma', (tester) async {
    final respuesta = await abrirDialogo(tester);

    await tester.tap(find.text('Salir'));
    await tester.pumpAndSettle();

    expect(respuesta(), isTrue);
  });

  testWidgets('Cancelar no confirma', (tester) async {
    final respuesta = await abrirDialogo(tester);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(respuesta(), isFalse);
  });

  testWidgets('cerrarlo tocando afuera no confirma', (tester) async {
    final respuesta = await abrirDialogo(tester);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(respuesta(), isFalse);
  });
}
