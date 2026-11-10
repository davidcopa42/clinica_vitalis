import 'package:clinica_vitalis/data/repositories/auth_repository.dart';
import 'package:clinica_vitalis/data/repositories/perfil_repository.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/ui/auth/view_models/sesion_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

// Repositorio Falso de Auth para los tests
class FakeAuthRepository implements AuthRepository {
  final String? _uidSimulado;
  final bool _correoVerificadoSimulado;

  FakeAuthRepository(
      {String? uidSimulado, bool correoVerificadoSimulado = true})
      : _uidSimulado = uidSimulado,
        _correoVerificadoSimulado = correoVerificadoSimulado;

  @override
  String? get uidActual => _uidSimulado;

  @override
  bool get correoVerificado => _correoVerificadoSimulado;

  @override
  Stream<String?> get cambiosDeSesion => Stream.value(_uidSimulado);

  @override
  Future<void> cerrarSesion() async {}

  @override
  Future<void> enviarVerificacion() async {}

  @override
  Future<void> iniciarConCorreo(String correo, String contrasena) async {}

  @override
  Future<void> iniciarConGoogle() async {}

  @override
  Future<void> recargarUsuario() async {}

  @override
  Future<void> recuperarContrasena(String correo) async {}

  @override
  Future<void> registrarConCorreo(String correo, String contrasena) async {}
}

// Repositorio Falso de Perfil adaptado al tipo exacto del repositorio real
class FakePerfilRepository implements PerfilRepository {
  final Map<String, dynamic>? datosPerfilSimulados;

  FakePerfilRepository({this.datosPerfilSimulados});

  @override
  Future<Map<String, dynamic>> cargarPerfilUsuario(String uid) async {
    return datosPerfilSimulados ?? {};
  }

  @override
  Future<void> guardarPerfil(
      String uid, Map<String, dynamic> datosPerfil) async {}

  @override
  Future<void> actualizarDatosPerfil(String uid,
      {String? nombre, String? telefono, String? obraSocial}) async {}

  @override
  Future<Paciente?> obtenerPerfil(String uid) async {
    if (datosPerfilSimulados == null) {
      return null;
    }
    return Paciente.fromMap(datosPerfilSimulados!);
  }
}

void main() {
  group('Pruebas de SesionViewModel', () {
    test('Debe retornar estado sinSesion si no hay UID', () async {
      final authRepo = FakeAuthRepository(uidSimulado: null);
      final perfilRepo = FakePerfilRepository();

      final sesionVM =
          SesionViewModel(authRepo: authRepo, perfilRepo: perfilRepo);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(sesionVM.estadoSesion, EstadoSesion.sinSesion);
    });

    test('Debe retornar correoSinVerificar si el correo no está verificado',
        () async {
      final authRepo = FakeAuthRepository(
          uidSimulado: '123', correoVerificadoSimulado: false);
      final perfilRepo = FakePerfilRepository();

      final sesionVM =
          SesionViewModel(authRepo: authRepo, perfilRepo: perfilRepo);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(sesionVM.estadoSesion, EstadoSesion.correoSinVerificar);
    });

    test('Debe retornar perfilIncompleto si el perfil en Firestore es nulo',
        () async {
      final authRepo = FakeAuthRepository(
          uidSimulado: '123', correoVerificadoSimulado: true);
      final perfilRepo = FakePerfilRepository(datosPerfilSimulados: null);

      final sesionVM =
          SesionViewModel(authRepo: authRepo, perfilRepo: perfilRepo);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(sesionVM.estadoSesion, EstadoSesion.perfilIncompleto);
    });

    test(
        'Debe retornar lista si el usuario está verificado y el perfil está completo',
        () async {
      final authRepo = FakeAuthRepository(
          uidSimulado: '123', correoVerificadoSimulado: true);

      final datosCompletos = {
        'uid': '123',
        'nombre': 'Josué',
        'apellido': 'Flores',
        'correo': 'josue@test.com',
        'telefono': '2611234567',
        'dni': '12345678',
        'fechaNacimiento': DateTime(2000, 1, 1).toIso8601String(),
      };

      final perfilRepo =
          FakePerfilRepository(datosPerfilSimulados: datosCompletos);

      final sesionVM =
          SesionViewModel(authRepo: authRepo, perfilRepo: perfilRepo);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(sesionVM.estadoSesion, EstadoSesion.lista);
    });
  });
}
