import 'package:clinica_vitalis/data/repositories/auth_repository.dart';
import 'package:clinica_vitalis/data/repositories/perfil_repository.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/usuario_autenticado.dart';
import 'package:clinica_vitalis/ui/perfil/view_models/perfil_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repositorio de perfil falso que guarda los datos en memoria.
class FakePerfilRepository implements PerfilRepository {
  FakePerfilRepository({this.datos});

  Map<String, dynamic>? datos;
  Object? errorAlCargar;
  Object? errorAlGuardar;
  final List<String> uidsCargados = [];
  final List<(String, Map<String, dynamic>)> guardados = [];

  @override
  Future<Map<String, dynamic>?> cargarPerfilUsuario(String uid) async {
    uidsCargados.add(uid);
    if (errorAlCargar != null) throw errorAlCargar!;
    return datos;
  }

  @override
  Future<void> guardarPerfil(
    String uid,
    Map<String, dynamic> datosPerfil,
  ) async {
    guardados.add((uid, datosPerfil));
    if (errorAlGuardar != null) throw errorAlGuardar!;
    datos = {...?datos, ...datosPerfil};
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

/// Repositorio de autenticacion falso que solo registra el cierre de sesion.
class FakeAuthRepository implements AuthRepository {
  int cierresDeSesion = 0;

  @override
  Future<void> cerrarSesion() async => cierresDeSesion++;

  @override
  Stream<String?> get cambiosDeSesion => const Stream.empty();

  @override
  String? get uidActual => null;

  @override
  bool get correoVerificado => false;

  @override
  Future<void> registrarConCorreo(String correo, String contrasena) async {}

  @override
  Future<void> iniciarConCorreo(String correo, String contrasena) async {}

  @override
  Future<UsuarioAutenticado?> iniciarConGoogle() async => null;

  @override
  Future<void> enviarVerificacion() async {}

  @override
  Future<void> recargarUsuario() async {}

  @override
  Future<void> actualizarNombreVisible(String nombre) async {}

  @override
  Future<void> recuperarContrasena(String correo) async {}
}

void main() {
  late FakePerfilRepository perfiles;
  late FakeAuthRepository auth;
  late PerfilViewModel viewModel;
  late List<bool> estadosDeCarga;

  void crearViewModel({Map<String, dynamic>? datos}) {
    perfiles = FakePerfilRepository(datos: datos);
    auth = FakeAuthRepository();
    viewModel = PerfilViewModel(repository: perfiles, authRepository: auth);
    estadosDeCarga = [];
    viewModel.addListener(() => estadosDeCarga.add(viewModel.isLoading));
  }

  setUp(() => crearViewModel(datos: {'nombre': 'Ana', 'dni': '123'}));

  tearDown(() => viewModel.dispose());

  test('empieza sin datos y sin cargar', () {
    expect(viewModel.perfilData, isNull);
    expect(viewModel.isLoading, isFalse);
  });

  group('cargarPerfil', () {
    test('la primera carga avisa cargando y despues los datos', () async {
      await viewModel.cargarPerfil('uid-1');

      expect(perfiles.uidsCargados, ['uid-1']);
      expect(viewModel.perfilData, {'nombre': 'Ana', 'dni': '123'});
      expect(viewModel.isLoading, isFalse);
      expect(estadosDeCarga, [true, false]);
    });

    test('si ya hay datos recarga sin volver a mostrar cargando', () async {
      await viewModel.cargarPerfil('uid-1');
      estadosDeCarga.clear();
      perfiles.datos = {'nombre': 'Ana María'};

      await viewModel.cargarPerfil('uid-1');

      expect(viewModel.perfilData, {'nombre': 'Ana María'});
      expect(estadosDeCarga, [false]);
    });

    test('si el perfil no existe queda en null', () async {
      crearViewModel();

      await viewModel.cargarPerfil('uid-1');

      expect(viewModel.perfilData, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('un error se traga: deja de cargar y conserva los datos previos',
        () async {
      await viewModel.cargarPerfil('uid-1');
      perfiles.errorAlCargar = Exception('sin red');

      await viewModel.cargarPerfil('uid-1');

      expect(viewModel.perfilData, {'nombre': 'Ana', 'dni': '123'});
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('actualizarPerfil', () {
    test('guarda los datos y vuelve a cargar el perfil', () async {
      await viewModel.cargarPerfil('uid-1');

      await viewModel.actualizarPerfil('uid-1', {'telefono': '261'});

      final (uidGuardado, datosGuardados) = perfiles.guardados.single;
      expect(uidGuardado, 'uid-1');
      expect(datosGuardados, {'telefono': '261'});
      expect(perfiles.uidsCargados, ['uid-1', 'uid-1']);
      expect(viewModel.perfilData!['telefono'], '261');
    });

    test('si falla el guardado el error se propaga y no recarga', () async {
      perfiles.errorAlGuardar = Exception('sin permiso');

      await expectLater(
        viewModel.actualizarPerfil('uid-1', {'telefono': '261'}),
        throwsException,
      );
      expect(perfiles.uidsCargados, isEmpty);
    });
  });

  test('cerrarSesion delega en el repositorio de autenticacion', () async {
    await viewModel.cerrarSesion();

    expect(auth.cierresDeSesion, 1);
  });
}
