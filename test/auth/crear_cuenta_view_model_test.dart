import 'package:clinica_vitalis/data/repositories/auth_repository.dart';
import 'package:clinica_vitalis/data/repositories/perfil_repository.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/usuario_autenticado.dart';
import 'package:clinica_vitalis/ui/auth/view_models/crear_cuenta_view_model.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';
import 'package:flutter_test/flutter_test.dart';

/// Registro compartido para verificar el orden de las llamadas.
final List<String> llamadas = [];

/// Repositorio de autenticacion falso que registra llamadas.
class FakeAuthRepository implements AuthRepository {
  String? uid = 'uid-nuevo';
  Object? errorAlRegistrar;
  Object? errorAlActualizarNombre;
  Object? errorAlEnviarVerificacion;

  @override
  String? get uidActual => uid;

  @override
  Future<void> registrarConCorreo(String correo, String contrasena) async {
    llamadas.add('registrar:$correo:$contrasena');
    if (errorAlRegistrar != null) throw errorAlRegistrar!;
  }

  @override
  Future<void> actualizarNombreVisible(String nombre) async {
    llamadas.add('nombre:$nombre');
    if (errorAlActualizarNombre != null) throw errorAlActualizarNombre!;
  }

  @override
  Future<void> enviarVerificacion() async {
    llamadas.add('verificacion');
    if (errorAlEnviarVerificacion != null) throw errorAlEnviarVerificacion!;
  }

  @override
  Stream<String?> get cambiosDeSesion => const Stream.empty();

  @override
  bool get correoVerificado => false;

  @override
  Future<void> iniciarConCorreo(String correo, String contrasena) async {}

  @override
  Future<UsuarioAutenticado?> iniciarConGoogle() async => null;

  @override
  Future<void> recargarUsuario() async {}

  @override
  Future<void> recuperarContrasena(String correo) async {}

  @override
  Future<void> cerrarSesion() async {}
}

/// Repositorio de perfil falso que registra lo que se guarda.
class FakePerfilRepository implements PerfilRepository {
  Object? errorAlGuardar;
  Map<String, dynamic>? perfilGuardado;

  @override
  Future<void> guardarPerfil(
    String uid,
    Map<String, dynamic> datosPerfil,
  ) async {
    llamadas.add('perfil:$uid');
    if (errorAlGuardar != null) throw errorAlGuardar!;
    perfilGuardado = datosPerfil;
  }

  @override
  Future<Map<String, dynamic>?> cargarPerfilUsuario(String uid) async => null;

  @override
  Future<Paciente?> obtenerPerfil(String uid) async => null;

  @override
  Future<void> actualizarDatosPerfil(
    String uid, {
    String? nombre,
    String? telefono,
    String? obraSocial,
  }) async {}
}

void main() {
  late FakeAuthRepository auth;
  late FakePerfilRepository perfiles;
  late CrearCuentaViewModel viewModel;
  late List<EstadoCarga> estados;

  setUp(() {
    llamadas.clear();
    auth = FakeAuthRepository();
    perfiles = FakePerfilRepository();
    viewModel = CrearCuentaViewModel(
      authRepository: auth,
      perfilRepository: perfiles,
    );
    estados = [];
    viewModel.addListener(() => estados.add(viewModel.estadoCarga));
  });

  tearDown(() => viewModel.dispose());

  Future<void> registrar() {
    return viewModel.registrarUsuario(
      nombre: ' Ana ',
      apellido: ' López ',
      correo: ' ana@test.com ',
      password: 'clave123',
    );
  }

  test('empieza en estado inicial y sin error', () {
    expect(viewModel.estadoCarga, EstadoCarga.inicial);
    expect(viewModel.mensajeError, isNull);
  });

  group('registro exitoso', () {
    test('registra, pone el nombre, guarda el perfil y envia verificacion',
        () async {
      await registrar();

      expect(llamadas, [
        'registrar: ana@test.com :clave123',
        'nombre:Ana López',
        'perfil:uid-nuevo',
        'verificacion',
      ]);
      expect(estados, [EstadoCarga.cargando, EstadoCarga.exito]);
      expect(viewModel.mensajeError, isNull);
    });

    test('guarda el perfil inicial con los datos recortados', () async {
      await registrar();

      // Fija el formato actual: fechaNacimiento '' y la clave 'photoUrl'
      // son los bugs 1 y 2 de la Fase D.
      expect(perfiles.perfilGuardado, {
        'nombre': 'Ana',
        'apellido': 'López',
        'correo': 'ana@test.com',
        'telefono': '',
        'dni': '',
        'fechaNacimiento': '',
        'obraSocial': 'Particular',
        'numeroAfiliado': '',
        'photoUrl': '',
      });
    });

    test('sin uid despues de registrar no guarda perfil ni envia verificacion',
        () async {
      auth.uid = null;

      await registrar();

      expect(llamadas, [
        'registrar: ana@test.com :clave123',
        'nombre:Ana López',
      ]);
      expect(viewModel.estadoCarga, EstadoCarga.exito);
    });
  });

  group('errores', () {
    test('una AuthException al registrar muestra su mensaje y corta', () async {
      auth.errorAlRegistrar =
          AuthException('Ya existe una cuenta con ese correo.');

      await registrar();

      expect(llamadas, ['registrar: ana@test.com :clave123']);
      expect(estados, [EstadoCarga.cargando, EstadoCarga.error]);
      expect(viewModel.mensajeError, 'Ya existe una cuenta con ese correo.');
    });

    test('una AuthException al enviar la verificacion muestra su mensaje',
        () async {
      auth.errorAlEnviarVerificacion =
          AuthException('Demasiados intentos. Probá en unos minutos.');

      await registrar();

      expect(perfiles.perfilGuardado, isNotNull);
      expect(viewModel.estadoCarga, EstadoCarga.error);
      expect(
        viewModel.mensajeError,
        'Demasiados intentos. Probá en unos minutos.',
      );
    });

    test('cualquier otro error muestra el mensaje generico', () async {
      perfiles.errorAlGuardar = Exception('sin permiso');

      await registrar();

      expect(viewModel.estadoCarga, EstadoCarga.error);
      expect(
        viewModel.mensajeError,
        'Ocurrió un error inesperado al registrarse.',
      );
      expect(llamadas, isNot(contains('verificacion')));
    });

    test('un error al poner el nombre tambien da el mensaje generico',
        () async {
      auth.errorAlActualizarNombre = Exception('falla');

      await registrar();

      expect(
        viewModel.mensajeError,
        'Ocurrió un error inesperado al registrarse.',
      );
      expect(perfiles.perfilGuardado, isNull);
    });

    test('un nuevo intento limpia el error anterior', () async {
      auth.errorAlRegistrar = AuthException('Error');
      await registrar();
      auth.errorAlRegistrar = null;
      final erroresDuranteIntento = <String?>[];
      viewModel.addListener(
        () => erroresDuranteIntento.add(viewModel.mensajeError),
      );

      await registrar();

      expect(erroresDuranteIntento, [null, null]);
      expect(viewModel.estadoCarga, EstadoCarga.exito);
    });
  });
}
