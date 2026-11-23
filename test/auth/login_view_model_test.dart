import 'package:clinica_vitalis/data/repositories/auth_repository.dart';
import 'package:clinica_vitalis/data/repositories/perfil_repository.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/usuario_autenticado.dart';
import 'package:clinica_vitalis/ui/auth/view_models/login_view_model.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repositorio de autenticacion falso para el login.
class FakeAuthRepository implements AuthRepository {
  final List<String> ingresos = [];
  Object? errorAlIngresar;
  Object? errorConGoogle;
  UsuarioAutenticado? usuarioDeGoogle = const UsuarioAutenticado(
    uid: 'uid-google',
    nombreVisible: 'Ana López',
    correo: 'ana@gmail.com',
    telefono: '+54261',
  );

  @override
  Future<void> iniciarConCorreo(String correo, String contrasena) async {
    ingresos.add('$correo:$contrasena');
    if (errorAlIngresar != null) throw errorAlIngresar!;
  }

  @override
  Future<UsuarioAutenticado?> iniciarConGoogle() async {
    if (errorConGoogle != null) throw errorConGoogle!;
    return usuarioDeGoogle;
  }

  @override
  Stream<String?> get cambiosDeSesion => const Stream.empty();

  @override
  String? get uidActual => null;

  @override
  UsuarioAutenticado? get usuarioActual => null;

  @override
  bool get correoVerificado => false;

  @override
  Future<void> registrarConCorreo(String correo, String contrasena) async {}

  @override
  Future<void> enviarVerificacion() async {}

  @override
  Future<void> recargarUsuario() async {}

  @override
  Future<void> actualizarNombreVisible(String nombre) async {}

  @override
  Future<void> recuperarContrasena(String correo) async {}

  @override
  Future<void> cerrarSesion() async {}
}

/// Repositorio de perfil falso para el primer ingreso con Google.
class FakePerfilRepository implements PerfilRepository {
  Map<String, dynamic>? perfilExistente;
  final List<String> consultados = [];
  final List<(String, Map<String, dynamic>)> guardados = [];

  @override
  Future<Map<String, dynamic>?> cargarPerfilUsuario(String uid) async {
    consultados.add(uid);
    return perfilExistente;
  }

  @override
  Future<void> guardarPerfil(
    String uid,
    Map<String, dynamic> datosPerfil,
  ) async {
    guardados.add((uid, datosPerfil));
  }

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
  late LoginViewModel viewModel;
  late List<EstadoCarga> estados;

  setUp(() {
    auth = FakeAuthRepository();
    perfiles = FakePerfilRepository();
    viewModel = LoginViewModel(
      authRepository: auth,
      perfilRepository: perfiles,
    );
    estados = [];
    viewModel.addListener(() => estados.add(viewModel.estadoCarga));
  });

  tearDown(() => viewModel.dispose());

  test('empieza en estado inicial, sin error y sin usuario nuevo', () {
    expect(viewModel.estadoCarga, EstadoCarga.inicial);
    expect(viewModel.mensajeError, isNull);
    expect(viewModel.esNuevoUsuario, isFalse);
  });

  group('iniciarSesion con correo', () {
    test('si sale bien pasa por cargando y termina en exito', () async {
      await viewModel.iniciarSesion('ana@test.com', 'clave123');

      expect(auth.ingresos, ['ana@test.com:clave123']);
      expect(estados, [EstadoCarga.cargando, EstadoCarga.exito]);
      expect(viewModel.mensajeError, isNull);
    });

    test('una AuthException muestra el mensaje traducido del repositorio',
        () async {
      auth.errorAlIngresar = AuthException('Correo o contraseña incorrectos.');

      await viewModel.iniciarSesion('ana@test.com', 'clave123');

      expect(viewModel.estadoCarga, EstadoCarga.error);
      expect(viewModel.mensajeError, 'Correo o contraseña incorrectos.');
    });

    test('un error que no es de autenticacion muestra su texto', () async {
      auth.errorAlIngresar = Exception('falla');

      await viewModel.iniciarSesion('ana@test.com', 'clave123');

      expect(viewModel.estadoCarga, EstadoCarga.error);
      expect(
          viewModel.mensajeError,
          'Ocurrió un error inesperado: '
          'Exception: falla');
    });

    test('un nuevo intento limpia el error anterior', () async {
      auth.errorAlIngresar = AuthException('Correo o contraseña incorrectos.');
      await viewModel.iniciarSesion('ana@test.com', 'mala');
      auth.errorAlIngresar = null;

      await viewModel.iniciarSesion('ana@test.com', 'clave123');

      expect(viewModel.mensajeError, isNull);
      expect(viewModel.estadoCarga, EstadoCarga.exito);
    });
  });

  group('iniciarSesionConGoogle', () {
    test('si el usuario cancela vuelve a inicial sin tocar el perfil',
        () async {
      auth.usuarioDeGoogle = null;

      await viewModel.iniciarSesionConGoogle();

      expect(
        estados,
        [EstadoCarga.cargando, EstadoCarga.inicial, EstadoCarga.inicial],
      );
      expect(perfiles.consultados, isEmpty);
      expect(viewModel.mensajeError, isNull);
    });

    test('primer ingreso: crea el perfil con los datos de Google', () async {
      await viewModel.iniciarSesionConGoogle();

      expect(perfiles.consultados, ['uid-google']);
      final (uid, datos) = perfiles.guardados.single;
      expect(uid, 'uid-google');
      // Formato de Paciente.toMap: el perfil queda incompleto hasta que el
      // paciente lo termine de cargar.
      expect(datos, {
        'uid': 'uid-google',
        'nombre': 'Ana López',
        'apellido': '',
        'correo': 'ana@gmail.com',
        'telefono': '+54261',
        'dni': '',
        'fechaNacimiento': null,
        'obraSocial': '',
        'numeroAfiliado': null,
        'fotoUrl': null,
      });
      expect(viewModel.esNuevoUsuario, isTrue);
      expect(estados, [EstadoCarga.cargando, EstadoCarga.exito]);
    });

    test('primer ingreso sin datos usa "Sin nombre" y textos vacios', () async {
      auth.usuarioDeGoogle = const UsuarioAutenticado(uid: 'uid-google');

      await viewModel.iniciarSesionConGoogle();

      final (_, datos) = perfiles.guardados.single;
      expect(datos['nombre'], 'Sin nombre');
      expect(datos['correo'], '');
      expect(datos['telefono'], '');
    });

    test('el perfil creado con Google se lee como Paciente incompleto',
        () async {
      await viewModel.iniciarSesionConGoogle();

      final (_, datos) = perfiles.guardados.single;
      final paciente = Paciente.fromMap(datos);
      expect(paciente.uid, 'uid-google');
      expect(paciente.nombre, 'Ana López');
      expect(paciente.perfilCompleto, isFalse);
    });

    test('un perfil vacio cuenta como primer ingreso', () async {
      perfiles.perfilExistente = {};

      await viewModel.iniciarSesionConGoogle();

      expect(perfiles.guardados, hasLength(1));
      expect(viewModel.esNuevoUsuario, isTrue);
    });

    test('con perfil existente no lo pisa', () async {
      perfiles.perfilExistente = {'nombre': 'Ana'};

      await viewModel.iniciarSesionConGoogle();

      expect(perfiles.guardados, isEmpty);
      expect(viewModel.esNuevoUsuario, isFalse);
      expect(viewModel.estadoCarga, EstadoCarga.exito);
    });

    test('un error de autenticacion muestra el mensaje traducido', () async {
      auth.errorConGoogle = AuthException('Sin conexión. Revisá internet.');

      await viewModel.iniciarSesionConGoogle();

      expect(viewModel.estadoCarga, EstadoCarga.error);
      expect(
        viewModel.mensajeError,
        'No se pudo iniciar sesión con Google: Sin conexión. Revisá internet.',
      );
    });

    test('cualquier otro error muestra su texto', () async {
      auth.errorConGoogle = Exception('sin Google Play');

      await viewModel.iniciarSesionConGoogle();

      expect(
        viewModel.mensajeError,
        'No se pudo iniciar sesión con Google: Exception: sin Google Play',
      );
    });
  });
}
