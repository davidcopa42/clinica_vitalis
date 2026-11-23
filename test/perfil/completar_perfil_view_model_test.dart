import 'package:clinica_vitalis/data/repositories/perfil_repository.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';
import 'package:clinica_vitalis/ui/perfil/view_models/completar_perfil_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_repository.dart';

/// Repositorio de perfil falso que registra lo guardado.
class FakePerfilRepository implements PerfilRepository {
  String? uidGuardado;
  Map<String, dynamic>? datosGuardados;
  Object? errorAlGuardar;

  @override
  Future<void> guardarPerfil(
    String uid,
    Map<String, dynamic> datosPerfil,
  ) async {
    if (errorAlGuardar != null) throw errorAlGuardar!;
    uidGuardado = uid;
    datosGuardados = datosPerfil;
  }

  @override
  Future<Map<String, dynamic>?> cargarPerfilUsuario(String uid) async => null;

  @override
  Future<Paciente?> obtenerPerfil(String uid) async => null;

}

void main() {
  late FakePerfilRepository perfiles;
  late FakeAuthRepository auth;
  late CompletarPerfilViewModel viewModel;
  late List<bool> guardando;

  setUp(() {
    perfiles = FakePerfilRepository();
    auth = FakeAuthRepository();
    viewModel = CompletarPerfilViewModel(
      perfilRepository: perfiles,
      authRepository: auth,
    );
    guardando = [];
    viewModel.addListener(() => guardando.add(viewModel.estaGuardando));
  });

  tearDown(() => viewModel.dispose());

  Future<String?> guardar({
    String obraSocial = 'OSDE',
    DateTime? fechaNacimiento,
  }) {
    return viewModel.guardarPerfil(
      uid: 'uid-1',
      nombre: ' Ana ',
      apellido: ' López ',
      correo: 'ana@test.com',
      dni: ' 30111222 ',
      fechaNacimiento: fechaNacimiento,
      telefono: ' 261555 ',
      obraSocial: obraSocial,
      numeroAfiliado: ' 9876 ',
    );
  }

  group('separarNombreInicial', () {
    test('la primera palabra es el nombre y el resto el apellido', () {
      final separado = viewModel.separarNombreInicial('Ana María López');

      expect(separado.nombre, 'Ana');
      expect(separado.apellido, 'María López');
    });

    test('una sola palabra no tiene apellido', () {
      final separado = viewModel.separarNombreInicial('Ana');

      expect(separado.nombre, 'Ana');
      expect(separado.apellido, '');
    });

    test('un nombre vacio da nombre y apellido vacios', () {
      final separado = viewModel.separarNombreInicial('');

      expect(separado.nombre, '');
      expect(separado.apellido, '');
    });
  });

  group('guardarPerfil', () {
    test('guarda los datos recortados y pasa por guardando', () async {
      final fecha = DateTime(1990, 5, 12);

      final error = await guardar(fechaNacimiento: fecha);

      expect(error, isNull);
      expect(perfiles.uidGuardado, 'uid-1');
      expect(perfiles.datosGuardados, {
        'uid': 'uid-1',
        'nombre': 'Ana',
        'apellido': 'López',
        'correo': 'ana@test.com',
        'telefono': '261555',
        'dni': '30111222',
        'fechaNacimiento': fecha.toIso8601String(),
        'obraSocial': 'OSDE',
        'numeroAfiliado': '9876',
        'fotoUrl': null,
      });
      expect(guardando, [true, false]);
      expect(viewModel.estado, EstadoCarga.exito);
    });

    test('con Particular el numero de afiliado queda vacio', () async {
      await guardar(obraSocial: 'Particular');

      expect(perfiles.datosGuardados!['numeroAfiliado'], '');
    });

    test('sin fecha de nacimiento la guarda como null', () async {
      await guardar();

      expect(perfiles.datosGuardados!['fechaNacimiento'], isNull);
    });

    test('si falla devuelve el mensaje de error', () async {
      perfiles.errorAlGuardar = Exception('sin permiso');

      final error = await guardar();

      expect(error, 'Error al guardar el perfil: Exception: sin permiso');
      expect(guardando, [true, false]);
      expect(viewModel.estado, EstadoCarga.error);
    });
  });

  test('cerrarSesion delega en el repositorio', () async {
    await viewModel.cerrarSesion();

    expect(auth.llamadas, ['cerrarSesion']);
  });
}
