import 'package:clinica_vitalis/ui/perfil/widgets/formulario_perfil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GlobalKey<FormState> claveFormulario;
  late TextEditingController dni;
  late TextEditingController telefono;

  Future<void> montarFormulario(WidgetTester tester) async {
    claveFormulario = GlobalKey<FormState>();
    dni = TextEditingController();
    telefono = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FormularioPerfil(
              formKey: claveFormulario,
              nombreController: TextEditingController(text: 'Ana'),
              apellidoController: TextEditingController(text: 'López'),
              dniController: dni,
              fechaNacimientoController:
                  TextEditingController(text: '12/05/1990'),
              telefonoController: telefono,
              obraSocialValue: 'Particular',
              onObraSocialChanged: (_) {},
              numeroAfiliadoController: TextEditingController(),
              onTapFecha: () {},
              onGuardar: () {},
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> validar(WidgetTester tester) async {
    final esValido = claveFormulario.currentState!.validate();
    await tester.pump();
    return esValido;
  }

  group('DNI', () {
    testWidgets('acepta 7 u 8 digitos', (tester) async {
      await montarFormulario(tester);
      telefono.text = '2615551234';

      dni.text = '1234567';
      expect(await validar(tester), isTrue);

      dni.text = '30111222';
      expect(await validar(tester), isTrue);
    });

    testWidgets('rechaza letras o una cantidad de digitos incorrecta',
        (tester) async {
      await montarFormulario(tester);
      telefono.text = '2615551234';

      for (final invalido in ['123456', '123456789', '30.111.222', 'abcdefg']) {
        dni.text = invalido;
        expect(await validar(tester), isFalse, reason: invalido);
        expect(find.text('Debe tener 7 u 8 dígitos'), findsOneWidget);
      }
    });
  });

  testWidgets('el desplegable ofrece todas las obras sociales', (tester) async {
    await montarFormulario(tester);

    await tester.tap(find.text('Particular'));
    await tester.pumpAndSettle();

    for (final obraSocial in [
      'Particular',
      'OSDE',
      'Swiss Medical',
      'Galeno',
      'PAMI',
      'IOMA',
      'Otra',
    ]) {
      expect(find.text(obraSocial), findsWidgets, reason: obraSocial);
    }
  });

  group('telefono', () {
    testWidgets('acepta entre 8 y 15 digitos', (tester) async {
      await montarFormulario(tester);
      dni.text = '30111222';

      for (final valido in ['26155512', '261555123456789']) {
        telefono.text = valido;
        expect(await validar(tester), isTrue, reason: valido);
      }
    });

    testWidgets('rechaza letras o una cantidad de digitos incorrecta',
        (tester) async {
      await montarFormulario(tester);
      dni.text = '30111222';

      for (final invalido in ['2615551', '2615551234567890', '261-555-12']) {
        telefono.text = invalido;
        expect(await validar(tester), isFalse, reason: invalido);
        expect(find.text('Debe tener entre 8 y 15 dígitos'), findsOneWidget);
      }
    });
  });
}
