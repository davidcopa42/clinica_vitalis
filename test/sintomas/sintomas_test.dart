import 'package:clinica_vitalis/data/repositories/sintomas_repository.dart';
import 'package:clinica_vitalis/domain/models/borrador_sintomas.dart';
import 'package:clinica_vitalis/ui/sintomas/view_models/sintomas_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Espera a que termine la carga del borrador que el ViewModel
/// arranca en su constructor.
Future<void> esperarCarga(SintomasViewModel viewModel) async {
  await Future<void>.delayed(Duration.zero);
}

void main() {
  late SintomasRepository repositorio;

  setUp(() {
    // Simula el almacenamiento del celular: cada test arranca vacío.
    SharedPreferences.setMockInitialValues({});
    repositorio = SintomasRepository();
  });

  group('SintomasRepository', () {
    test('sin nada guardado devuelve null', () async {
      expect(await repositorio.cargarBorrador(), isNull);
    });

    test('guarda y vuelve a cargar el mismo borrador', () async {
      await repositorio.guardarBorrador(
        const BorradorSintomas(
          sintomas: ['Fiebre', 'Tos'],
          descripcion: 'Empezó a la noche',
          duracion: '2-3 días',
          intensidad: 6,
        ),
      );

      final borrador = await repositorio.cargarBorrador();

      expect(borrador, isNotNull);
      expect(borrador!.sintomas, ['Fiebre', 'Tos']);
      expect(borrador.descripcion, 'Empezó a la noche');
      expect(borrador.duracion, '2-3 días');
      expect(borrador.intensidad, 6);
    });

    test('eliminarBorrador deja el almacenamiento vacío', () async {
      await repositorio.guardarBorrador(
        const BorradorSintomas(sintomas: ['Mareos']),
      );

      await repositorio.eliminarBorrador();

      expect(await repositorio.cargarBorrador(), isNull);
    });
  });

  group('SintomasViewModel', () {
    test('al crearse carga el borrador guardado', () async {
      await repositorio.guardarBorrador(
        const BorradorSintomas(
          sintomas: ['Dolor de cabeza'],
          descripcion: 'Desde ayer',
          duracion: 'Hoy',
          intensidad: 4,
        ),
      );

      final viewModel = SintomasViewModel(repositorio: repositorio);
      await esperarCarga(viewModel);

      expect(viewModel.sintomasSeleccionados, {'Dolor de cabeza'});
      expect(viewModel.descripcion, 'Desde ayer');
      expect(viewModel.intensidad, 4);
    });

    test('cada cambio se guarda en el borrador', () async {
      final viewModel = SintomasViewModel(repositorio: repositorio);
      await esperarCarga(viewModel);

      viewModel.cambiarSintoma('Fiebre');
      viewModel.cambiarIntensidad(7);
      await viewModel.guardarBorrador();

      final borrador = await repositorio.cargarBorrador();
      expect(borrador!.sintomas, ['Fiebre']);
      expect(borrador.intensidad, 7);
    });

    test('registrar los síntomas borra el borrador', () async {
      final viewModel = SintomasViewModel(repositorio: repositorio);
      await esperarCarga(viewModel);
      viewModel.cambiarSintoma('Tos');
      await viewModel.guardarBorrador();

      await viewModel.registrarSintomas();

      expect(viewModel.registrado, isTrue);
      expect(await repositorio.cargarBorrador(), isNull);
    });
  });
}
