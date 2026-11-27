import 'package:clinica_vitalis/data/repositories/auth_repository.dart';
import 'package:clinica_vitalis/ui/auth/view_models/recuperar_contrasena_view_model.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository auth;
  late RecuperarContrasenaViewModel viewModel;
  late List<bool> enviando;

  setUp(() {
    auth = FakeAuthRepository();
    viewModel = RecuperarContrasenaViewModel(authRepository: auth);
    enviando = [];
    viewModel.addListener(() => enviando.add(viewModel.estaEnviando));
  });

  tearDown(() => viewModel.dispose());

  test('empieza en estado inicial y sin enviar', () {
    expect(viewModel.estado, EstadoCarga.inicial);
    expect(viewModel.estaEnviando, isFalse);
  });

  test('pide el enlace al repositorio con el correo recibido', () async {
    await viewModel.enviarEnlace('ana@test.com');

    expect(auth.llamadas, ['recuperarContrasena:ana@test.com']);
    expect(enviando, [true, false]);
    expect(viewModel.estado, EstadoCarga.exito);
  });

  test('si el repositorio falla termina igual en exito, sin avisar', () async {
    auth.errores['recuperarContrasena'] =
        AuthException('El correo no es válido.');

    await viewModel.enviarEnlace('no-existe@test.com');

    expect(enviando, [true, false]);
    expect(viewModel.estado, EstadoCarga.exito);
  });
}
