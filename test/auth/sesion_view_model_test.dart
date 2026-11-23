import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/ui/auth/view_models/estado_sesion.dart';
import 'package:clinica_vitalis/ui/auth/view_models/sesion_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_perfil_repository.dart';

final pacienteCompleto = Paciente(
  uid: '123',
  nombre: 'Josué',
  apellido: 'Flores',
  correo: 'josue@test.com',
  telefono: '2611234567',
  dni: '12345678',
  fechaNacimiento: DateTime(2000, 1, 1),
);

Future<SesionViewModel> crearSesion({
  required FakeAuthRepository authRepository,
  Paciente? paciente,
}) async {
  final viewModel = SesionViewModel(
    authRepository: authRepository,
    perfilRepository: FakePerfilRepository(paciente: paciente),
  );
  await pumpEventQueue();
  return viewModel;
}

void main() {
  group('SesionViewModel', () {
    test('queda en sinSesion si no hay uid', () async {
      final viewModel = await crearSesion(
        authRepository: FakeAuthRepository(uidActual: null),
      );

      expect(viewModel.estadoSesion, EstadoSesion.sinSesion);
      expect(viewModel.estaCargando, isFalse);
    });

    test('queda en correoSinVerificar si el correo no esta verificado',
        () async {
      final viewModel = await crearSesion(
        authRepository: FakeAuthRepository(
          uidActual: '123',
          correoVerificado: false,
        ),
      );

      expect(viewModel.estadoSesion, EstadoSesion.correoSinVerificar);
    });

    test('queda en perfilIncompleto si no hay perfil guardado', () async {
      final viewModel = await crearSesion(
        authRepository: FakeAuthRepository(uidActual: '123'),
      );

      expect(viewModel.estadoSesion, EstadoSesion.perfilIncompleto);
    });

    test('queda en lista si el correo esta verificado y el perfil completo',
        () async {
      final viewModel = await crearSesion(
        authRepository: FakeAuthRepository(uidActual: '123'),
        paciente: pacienteCompleto,
      );

      expect(viewModel.estadoSesion, EstadoSesion.lista);
      expect(viewModel.pacienteActual, pacienteCompleto);
    });

    test('recargarSesion pasa a lista cuando el correo se verifica', () async {
      final authRepository = FakeAuthRepository(
        uidActual: '123',
        correoVerificado: false,
      );
      final viewModel = await crearSesion(
        authRepository: authRepository,
        paciente: pacienteCompleto,
      );

      authRepository.correoVerificado = true;
      await viewModel.recargarSesion();

      expect(authRepository.vecesRecargado, 1);
      expect(viewModel.estadoSesion, EstadoSesion.lista);
    });
  });
}
