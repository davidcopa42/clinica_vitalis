import 'package:clinica_vitalis/data/repositories/auth_repository.dart';
import 'package:clinica_vitalis/data/repositories/perfil_repository.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/usuario_autenticado.dart';
import 'package:clinica_vitalis/ui/auth/view_models/sesion_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_repository.dart' as compartido;

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

  UsuarioAutenticado? usuario;

  @override
  UsuarioAutenticado? get usuarioActual => usuario;

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
  Future<UsuarioAutenticado?> iniciarConGoogle() async => null;

  @override
  Future<void> recargarUsuario() async {}

  @override
  Future<void> actualizarNombreVisible(String nombre) async {}

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

      final sesionViewModel =
          SesionViewModel(authRepo: authRepo, perfilRepo: perfilRepo);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(sesionViewModel.estadoSesion, EstadoSesion.sinSesion);
    });

    test('Debe retornar correoSinVerificar si el correo no está verificado',
        () async {
      final authRepo = FakeAuthRepository(
          uidSimulado: '123', correoVerificadoSimulado: false);
      final perfilRepo = FakePerfilRepository();

      final sesionViewModel =
          SesionViewModel(authRepo: authRepo, perfilRepo: perfilRepo);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(sesionViewModel.estadoSesion, EstadoSesion.correoSinVerificar);
    });

    test('Debe retornar perfilIncompleto si el perfil en Firestore es nulo',
        () async {
      final authRepo = FakeAuthRepository(
          uidSimulado: '123', correoVerificadoSimulado: true);
      final perfilRepo = FakePerfilRepository(datosPerfilSimulados: null);

      final sesionViewModel =
          SesionViewModel(authRepo: authRepo, perfilRepo: perfilRepo);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(sesionViewModel.estadoSesion, EstadoSesion.perfilIncompleto);
    });

    test(
        'un perfil recien registrado (fechaNacimiento vacia) queda '
        'incompleto pero con el paciente cargado', () async {
      final authRepo = FakeAuthRepository(
          uidSimulado: '123', correoVerificadoSimulado: true);
      final perfilRepo = FakePerfilRepository(datosPerfilSimulados: {
        'uid': '123',
        'nombre': 'Ana',
        'apellido': 'López',
        'correo': 'ana@test.com',
        'telefono': '',
        'dni': '',
        'fechaNacimiento': '',
      });

      final sesionViewModel =
          SesionViewModel(authRepo: authRepo, perfilRepo: perfilRepo);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(sesionViewModel.estadoSesion, EstadoSesion.perfilIncompleto);
      expect(sesionViewModel.pacienteActual?.nombre, 'Ana');
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

      final sesionViewModel =
          SesionViewModel(authRepo: authRepo, perfilRepo: perfilRepo);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(sesionViewModel.estadoSesion, EstadoSesion.lista);
    });

    test('usuarioActual expone los datos de la cuenta del repositorio', () {
      final authRepo = FakeAuthRepository(uidSimulado: '123')
        ..usuario = const UsuarioAutenticado(
          uid: '123',
          nombreVisible: 'Ana López',
          correo: 'ana@test.com',
        );

      final sesionViewModel = SesionViewModel(
        authRepo: authRepo,
        perfilRepo: FakePerfilRepository(),
      );
      addTearDown(sesionViewModel.dispose);

      expect(sesionViewModel.usuarioActual!.correo, 'ana@test.com');
      expect(sesionViewModel.usuarioActual!.nombreVisible, 'Ana López');
    });

    test('recargarYCalcular deja de cargar y recalcula aunque falle la recarga',
        () async {
      final authRepo = compartido.FakeAuthRepository()
        ..uid = '123'
        ..errores['recargarUsuario'] = Exception('sin red');
      final sesionViewModel = SesionViewModel(
        authRepo: authRepo,
        perfilRepo: FakePerfilRepository(),
      );
      addTearDown(sesionViewModel.dispose);
      await pumpEventQueue();

      await sesionViewModel.recargarYCalcular();

      expect(authRepo.llamadas, contains('recargarUsuario'));
      expect(sesionViewModel.estaCargando, isFalse);
      expect(sesionViewModel.estadoSesion, EstadoSesion.correoSinVerificar);
    });
  });
}
