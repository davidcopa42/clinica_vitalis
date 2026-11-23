import 'package:clinica_vitalis/data/repositories/auth_repository.dart';
import 'package:clinica_vitalis/ui/auth/view_models/verificar_correo_view_model.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository auth;
  late VerificarCorreoViewModel viewModel;
  late int avisosDeVerificacion;

  setUp(() {
    auth = FakeAuthRepository();
    avisosDeVerificacion = 0;
    viewModel = VerificarCorreoViewModel(
      authRepository: auth,
      alVerificarCorreo: () => avisosDeVerificacion++,
    );
  });

  tearDown(() => viewModel.dispose());

  int recargas() =>
      auth.llamadas.where((llamada) => llamada == 'recargarUsuario').length;

  group('verificacion automatica', () {
    test('recarga el usuario cada 3 segundos', () {
      fakeAsync((tiempo) {
        viewModel.iniciarVerificacionAutomatica();

        tiempo.elapse(const Duration(seconds: 2));
        expect(recargas(), 0);

        tiempo.elapse(const Duration(seconds: 7));
        expect(recargas(), 3);
        expect(avisosDeVerificacion, 0);
      });
    });

    test('cuando el correo queda verificado avisa una vez y deja de revisar',
        () {
      fakeAsync((tiempo) {
        viewModel.iniciarVerificacionAutomatica();
        tiempo.elapse(const Duration(seconds: 3));
        auth.verificadoAlRecargar = true;

        tiempo.elapse(const Duration(seconds: 3));
        expect(avisosDeVerificacion, 1);

        tiempo.elapse(const Duration(seconds: 30));
        expect(recargas(), 2);
        expect(avisosDeVerificacion, 1);
      });
    });
  });

  group('comprobarVerificacion manual', () {
    test('sin verificar no avisa', () async {
      await viewModel.comprobarVerificacion();

      expect(recargas(), 1);
      expect(avisosDeVerificacion, 0);
    });

    test('verificado avisa cada vez que se comprueba', () async {
      auth.verificadoAlRecargar = true;

      await viewModel.comprobarVerificacion();
      await viewModel.comprobarVerificacion();

      expect(avisosDeVerificacion, 2);
    });

    test('un error al recargar se propaga', () async {
      auth.errores['recargarUsuario'] = AuthException('Sin conexión.');

      await expectLater(
        viewModel.comprobarVerificacion(),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('reenviar correo', () {
    test('al principio se puede reenviar', () {
      expect(viewModel.puedeReenviar, isTrue);
      expect(viewModel.segundosRestantes, 0);
    });

    test('reenvia y bloquea el boton 60 segundos con cuenta regresiva', () {
      fakeAsync((tiempo) {
        String? error = 'sin respuesta';
        viewModel.reenviarCorreo().then((resultado) => error = resultado);
        tiempo.flushMicrotasks();

        expect(error, isNull);
        expect(auth.llamadas, ['enviarVerificacion']);
        expect(viewModel.puedeReenviar, isFalse);
        expect(viewModel.segundosRestantes, 60);

        tiempo.elapse(const Duration(seconds: 1));
        expect(viewModel.segundosRestantes, 59);

        tiempo.elapse(const Duration(seconds: 59));
        expect(viewModel.segundosRestantes, 0);
        expect(viewModel.puedeReenviar, isFalse);

        tiempo.elapse(const Duration(seconds: 1));
        expect(viewModel.puedeReenviar, isTrue);
      });
    });

    test('si falla devuelve el mensaje y no bloquea el boton', () async {
      auth.errores['enviarVerificacion'] =
          AuthException('Demasiados intentos. Probá en unos minutos.');

      final error = await viewModel.reenviarCorreo();

      expect(
        error,
        'Error al reenviar: Demasiados intentos. Probá en unos minutos.',
      );
      expect(viewModel.puedeReenviar, isTrue);
    });
  });

  test('cerrarSesion delega en el repositorio', () async {
    await viewModel.cerrarSesion();

    expect(auth.llamadas, ['cerrarSesion']);
  });
}
