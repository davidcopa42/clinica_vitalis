import 'package:clinica_vitalis/ui/core/mensaje_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra el icono, el mensaje y reintenta al tocar el boton',
      (tester) async {
    var reintentos = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MensajeError(
            mensaje: 'No se pudieron cargar tus turnos.',
            alReintentar: () => reintentos++,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('No se pudieron cargar tus turnos.'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));

    expect(reintentos, 1);
  });
}
