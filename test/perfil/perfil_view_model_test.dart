import 'package:clinica_vitalis/data/repositories/auth_repository.dart';
import 'package:clinica_vitalis/data/repositories/perfil_repository.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/usuario_autenticado.dart';
import 'package:clinica_vitalis/ui/perfil/view_models/perfil_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repositorio de perfil falso que guarda el documento en memoria.
class FakePerfilRepository implements PerfilRepository {
  FakePerfilRepository({this.datos});

  Map<String, dynamic>? datos;
  Object? errorAlCargar;
  Object? errorAlGuardar;
  final List<String> uidsCargados = [];
  final List<(String, Map<String, dynamic>)> guardados = [];

  @override
  Future<Paciente?> obtenerPerfil(String uid) async {
    uidsCargados.add(uid);
    if (errorAlCargar != null) throw errorAlCargar!;
    final documento = datos;
    return documento == null ? null : Paciente.fromMap(documento);
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
  Future<Map<String, dynamic>?> cargarPerfilUsuario(String uid) async => datos;
}

/// Repositorio de autenticacion falso que solo registra el cierre de sesion.
class FakeAuthRepository implements AuthRepository {
  int cierresDeSesion = 0;
  UsuarioAutenticado? usuario;

  @override
  Future<void> cerrarSesion() async => cierresDeSesion++;

  @override
  Stream<String?> get cambiosDeSesion => const Stream.empty();

  @override
  String? get uidActual => null;

  @override
  UsuarioAutenticado? get usuarioActual => usuario;

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
    viewModel.addListener(() => estadosDeCarga.add(viewModel.estaCargando));
  }

  setUp(
    () =>
        crearViewModel(datos: {'uid': 'uid-1', 'nombre': 'Ana', 'dni': '123'}),
  );

  tearDown(() => viewModel.dispose());

  test('empieza sin paciente y sin cargar', () {
    expect(viewModel.paciente, isNull);
    expect(viewModel.estaCargando, isFalse);
  });

  group('cargarPerfil', () {
    test('la primera carga avisa cargando y despues el paciente', () async {
      await viewModel.cargarPerfil('uid-1');

      expect(perfiles.uidsCargados, ['uid-1']);
      expect(viewModel.paciente!.nombre, 'Ana');
      expect(viewModel.paciente!.dni, '123');
      expect(viewModel.estaCargando, isFalse);
      expect(estadosDeCarga, [true, false]);
    });

    test('carga un perfil recien registrado con fechaNacimiento vacia',
        () async {
      crearViewModel(datos: {'nombre': 'Ana', 'fechaNacimiento': ''});

      await viewModel.cargarPerfil('uid-1');

      expect(viewModel.paciente!.nombre, 'Ana');
      expect(viewModel.paciente!.fechaNacimiento, isNull);
    });

    test('si ya hay datos recarga sin volver a mostrar cargando', () async {
      await viewModel.cargarPerfil('uid-1');
      estadosDeCarga.clear();
      perfiles.datos = {'nombre': 'Ana María'};

      await viewModel.cargarPerfil('uid-1');

      expect(viewModel.paciente!.nombre, 'Ana María');
      expect(estadosDeCarga, [false]);
    });

    test('si el perfil no existe queda en null', () async {
      crearViewModel();

      await viewModel.cargarPerfil('uid-1');

      expect(viewModel.paciente, isNull);
      expect(viewModel.estaCargando, isFalse);
    });

    test('un error se traga: deja de cargar y conserva el paciente previo',
        () async {
      await viewModel.cargarPerfil('uid-1');
      perfiles.errorAlCargar = Exception('sin red');

      await viewModel.cargarPerfil('uid-1');

      expect(viewModel.paciente!.nombre, 'Ana');
      expect(viewModel.estaCargando, isFalse);
    });
  });

  group('actualizarPerfil', () {
    test('guarda el paciente con toMap y vuelve a cargar el perfil', () async {
      await viewModel.cargarPerfil('uid-1');
      final actualizado = viewModel.paciente!.copyWith(telefono: '261');

      await viewModel.actualizarPerfil('uid-1', actualizado);

      final (uidGuardado, datosGuardados) = perfiles.guardados.single;
      expect(uidGuardado, 'uid-1');
      expect(datosGuardados, actualizado.toMap());
      expect(perfiles.uidsCargados, ['uid-1', 'uid-1']);
      expect(viewModel.paciente!.telefono, '261');
    });

    test('si falla el guardado el error se propaga y no recarga', () async {
      perfiles.errorAlGuardar = Exception('sin permiso');
      const paciente = Paciente(
        uid: 'uid-1',
        nombre: 'Ana',
        apellido: 'López',
        correo: 'ana@test.com',
      );

      await expectLater(
        viewModel.actualizarPerfil('uid-1', paciente),
        throwsException,
      );
      expect(perfiles.uidsCargados, isEmpty);
    });
  });

  test('cerrarSesion delega en el repositorio de autenticacion', () async {
    await viewModel.cerrarSesion();

    expect(auth.cierresDeSesion, 1);
  });

  group('textos para mostrar', () {
    test('sin paciente todo dice No registrado', () {
      expect(viewModel.nombreCompletoTexto, 'No registrado');
      expect(viewModel.dniTexto, 'No registrado');
      expect(viewModel.telefonoTexto, 'No registrado');
      expect(viewModel.fechaNacimientoTexto, 'No registrado');
      expect(viewModel.obraSocialTexto, 'No registrado');
    });

    test('con un perfil completo formatea cada dato', () async {
      crearViewModel(datos: {
        'nombre': 'Ana',
        'apellido': 'López',
        'dni': '30111222',
        'telefono': '2615551234',
        'fechaNacimiento': DateTime(1990, 5, 12).toIso8601String(),
        'obraSocial': 'OSDE',
        'numeroAfiliado': '9876',
      });

      await viewModel.cargarPerfil('uid-1');

      expect(viewModel.nombreCompletoTexto, 'Ana López');
      expect(viewModel.dniTexto, '30111222');
      expect(viewModel.telefonoTexto, '2615551234');
      expect(viewModel.fechaNacimientoTexto, '12/05/1990');
      expect(viewModel.obraSocialTexto, 'OSDE (Nº 9876)');
    });

    test('solo nombre, sin apellido, no deja espacios de mas', () async {
      crearViewModel(datos: {'nombre': 'Ana'});

      await viewModel.cargarPerfil('uid-1');

      expect(viewModel.nombreCompletoTexto, 'Ana');
    });

    test('Particular o sin numero de afiliado muestra solo la obra social',
        () async {
      crearViewModel(
        datos: {'obraSocial': 'Particular', 'numeroAfiliado': '123'},
      );
      await viewModel.cargarPerfil('uid-1');
      expect(viewModel.obraSocialTexto, 'Particular');

      crearViewModel(datos: {'obraSocial': 'OSDE', 'numeroAfiliado': ''});
      await viewModel.cargarPerfil('uid-1');
      expect(viewModel.obraSocialTexto, 'OSDE');
    });
  });

  group('datos de la cuenta', () {
    test('sin usuario no hay foto y el correo dice "Sin correo electronico"',
        () {
      expect(viewModel.fotoUrl, isNull);
      expect(viewModel.correoActual, 'Sin correo electrónico');
    });

    test('con usuario expone su foto y su correo', () {
      auth.usuario = const UsuarioAutenticado(
        uid: 'uid-1',
        correo: 'ana@test.com',
        fotoUrl: 'https://foto.com/ana.png',
      );

      expect(viewModel.fotoUrl, 'https://foto.com/ana.png');
      expect(viewModel.correoActual, 'ana@test.com');
    });
  });
}
