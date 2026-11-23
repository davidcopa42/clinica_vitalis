import 'package:clinica_vitalis/data/repositories/borrador_repositorio_local.dart';
import 'package:clinica_vitalis/data/services/borrador_service.dart';
import 'package:clinica_vitalis/ui/sintomas/view_models/sintomas_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const claveLista = 'borrador_sintomas_lista';
const claveDescripcion = 'borrador_sintomas_desc';
const claveDuracion = 'borrador_sintomas_duracion';
const claveIntensidad = 'borrador_sintomas_intensidad';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SintomasViewModel viewModel;

  /// Crea el ViewModel y espera a que termine de leer el borrador.
  Future<SintomasViewModel> crearViewModel() async {
    final nuevo = SintomasViewModel(
      borradorRepository:
          BorradorRepositorioLocal(borradorService: BorradorService()),
    );
    await pumpEventQueue();
    return nuevo;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    viewModel = await crearViewModel();
  });

  tearDown(() => viewModel.dispose());

  group('estado inicial', () {
    test('sin borrador arranca con los valores por defecto', () {
      expect(viewModel.sintomasSeleccionados, isEmpty);
      expect(viewModel.descripcion, '');
      expect(viewModel.duracion, 'Hoy');
      expect(viewModel.intensidad, 1);
      expect(viewModel.registrado, isFalse);
      expect(viewModel.tieneSignosAlarma, isFalse);
    });

    test('ofrece los 13 sintomas disponibles', () {
      expect(viewModel.sintomasDisponibles, hasLength(13));
      expect(viewModel.sintomasDisponibles.first, 'Dolor de cabeza');
      expect(
        viewModel.sintomasDisponibles.last,
        'Dificultad para hablar o mover un lado del cuerpo',
      );
    });

    test('restaura el borrador guardado', () async {
      viewModel.dispose();
      SharedPreferences.setMockInitialValues({
        claveLista: ['Fiebre', 'Tos'],
        claveDescripcion: 'Desde anoche',
        claveDuracion: 'Más de una semana',
        claveIntensidad: 6.0,
      });

      viewModel = await crearViewModel();

      expect(viewModel.sintomasSeleccionados, {'Fiebre', 'Tos'});
      expect(viewModel.descripcion, 'Desde anoche');
      expect(viewModel.duracion, 'Más de una semana');
      expect(viewModel.intensidad, 6.0);
      expect(viewModel.registrado, isFalse);
    });
  });

  group('cambios del formulario', () {
    test('cambiarSintoma agrega y vuelve a quitar el sintoma', () {
      viewModel.cambiarSintoma('Fiebre');
      expect(viewModel.sintomasSeleccionados, {'Fiebre'});

      viewModel.cambiarSintoma('Fiebre');
      expect(viewModel.sintomasSeleccionados, isEmpty);
    });

    test('cada cambio notifica y guarda el borrador', () async {
      var notificaciones = 0;
      viewModel.addListener(() => notificaciones++);

      viewModel.cambiarSintoma('Tos');
      viewModel.cambiarDescripcion('Seca');
      viewModel.cambiarDuracion('Ayer');
      viewModel.cambiarIntensidad(4);
      await pumpEventQueue();

      expect(notificaciones, 4);
      final preferencias = await SharedPreferences.getInstance();
      expect(preferencias.getStringList(claveLista), ['Tos']);
      expect(preferencias.getString(claveDescripcion), 'Seca');
      expect(preferencias.getString(claveDuracion), 'Ayer');
      expect(preferencias.getDouble(claveIntensidad), 4);
    });

    test('las colecciones expuestas no se pueden modificar', () {
      expect(
        () => viewModel.sintomasDisponibles.add('Otro'),
        throwsUnsupportedError,
      );
      expect(
        () => viewModel.sintomasSeleccionados.add('Otro'),
        throwsUnsupportedError,
      );
    });
  });

  group('tieneSignosAlarma', () {
    test('es true con un sintoma de alarma', () {
      viewModel.cambiarSintoma('Dolor de pecho');

      expect(viewModel.tieneSignosAlarma, isTrue);
    });

    test('es false con sintomas comunes e intensidad baja', () {
      viewModel.cambiarSintoma('Fiebre');
      viewModel.cambiarIntensidad(8.9);

      expect(viewModel.tieneSignosAlarma, isFalse);
    });

    test('es true con intensidad 9 o mas aunque no haya sintomas', () {
      viewModel.cambiarIntensidad(9);

      expect(viewModel.tieneSignosAlarma, isTrue);
    });
  });

  group('registrarSintomas', () {
    test('marca registrado y borra todas las claves del borrador', () async {
      viewModel.cambiarSintoma('Tos');
      viewModel.cambiarDescripcion('Seca');
      await pumpEventQueue();

      await viewModel.registrarSintomas();

      expect(viewModel.registrado, isTrue);
      final preferencias = await SharedPreferences.getInstance();
      for (final clave in [
        claveLista,
        claveDescripcion,
        claveDuracion,
        claveIntensidad,
      ]) {
        expect(preferencias.containsKey(clave), isFalse, reason: clave);
      }
    });

    test('conserva en memoria lo cargado despues de registrar', () async {
      viewModel.cambiarSintoma('Tos');

      await viewModel.registrarSintomas();

      expect(viewModel.sintomasSeleccionados, {'Tos'});
    });

    test('cualquier cambio posterior vuelve registrado a false', () async {
      await viewModel.registrarSintomas();

      viewModel.cambiarDuracion('Ayer');

      expect(viewModel.registrado, isFalse);
    });
  });

  group('textos y estados para la pantalla', () {
    test('la intensidad se muestra redondeada y sobre 10', () {
      viewModel.cambiarIntensidad(4.4);

      expect(viewModel.intensidadEtiqueta, '4');
      expect(viewModel.intensidadTexto, 'Intensidad: 4 / 10');
    });

    test('sin registrar no muestra ninguna confirmacion', () {
      expect(viewModel.mostrarRecomendacionDeTurno, isFalse);
      expect(viewModel.mostrarRegistroConAlarma, isFalse);
      expect(viewModel.puedeSolicitarTurno, isTrue);
    });

    test('registrado sin alarma recomienda turno', () async {
      viewModel.cambiarSintoma('Tos');
      await viewModel.registrarSintomas();

      expect(viewModel.mostrarRecomendacionDeTurno, isTrue);
      expect(viewModel.mostrarRegistroConAlarma, isFalse);
    });

    test('registrado con alarma solo confirma y no ofrece turno', () async {
      viewModel.cambiarSintoma('Dolor de pecho');
      await viewModel.registrarSintomas();

      expect(viewModel.mostrarRecomendacionDeTurno, isFalse);
      expect(viewModel.mostrarRegistroConAlarma, isTrue);
      expect(viewModel.puedeSolicitarTurno, isFalse);
    });
  });

  group('refrescar', () {
    test('vuelve a aplicar los valores guardados en SharedPreferences',
        () async {
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.setString(claveDescripcion, 'Cambiado afuera');

      await viewModel.refrescar();

      expect(viewModel.descripcion, 'Cambiado afuera');
    });

    test('reemplaza los sintomas seleccionados por los guardados', () async {
      viewModel.cambiarSintoma('Tos');
      await pumpEventQueue();
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.setStringList(claveLista, ['Fiebre']);

      await viewModel.refrescar();

      expect(viewModel.sintomasSeleccionados, {'Fiebre'});
    });
  });
}
