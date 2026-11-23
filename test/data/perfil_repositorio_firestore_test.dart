import 'package:clinica_vitalis/data/repositories/perfil_repositorio_firestore.dart';
import 'package:clinica_vitalis/data/services/perfil_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Servicio de perfil falso que guarda los documentos en memoria.
class FakePerfilService implements PerfilService {
  final Map<String, Map<String, dynamic>> documentos = {};

  @override
  Future<Map<String, dynamic>?> obtenerPerfil(String uid) async =>
      documentos[uid];

  @override
  Future<void> guardarPerfil(
    String uid,
    Map<String, dynamic> datosPerfil,
  ) async {
    documentos[uid] = {...?documentos[uid], ...datosPerfil};
  }
}

void main() {
  late FakePerfilService servicio;
  late PerfilRepositorioFirestore repositorio;

  setUp(() {
    servicio = FakePerfilService();
    repositorio = PerfilRepositorioFirestore(perfilService: servicio);
  });

  group('obtenerPerfil', () {
    test('sin documento devuelve null', () async {
      expect(await repositorio.obtenerPerfil('uid-1'), isNull);
    });

    test('convierte el documento en Paciente', () async {
      servicio.documentos['uid-1'] = {
        'uid': 'uid-1',
        'nombre': 'Ana',
        'apellido': 'López',
      };

      final paciente = await repositorio.obtenerPerfil('uid-1');

      expect(paciente!.nombre, 'Ana');
      expect(paciente.apellido, 'López');
    });

    test('completa el uid si el documento no lo tiene', () async {
      servicio.documentos['uid-1'] = {'nombre': 'Ana'};

      expect((await repositorio.obtenerPerfil('uid-1'))!.uid, 'uid-1');
    });

    test('completa el uid si viene null o vacio', () async {
      servicio.documentos['uid-1'] = {'uid': null, 'nombre': 'Ana'};
      servicio.documentos['uid-2'] = {'uid': '', 'nombre': 'Bea'};

      expect((await repositorio.obtenerPerfil('uid-1'))!.uid, 'uid-1');
      expect((await repositorio.obtenerPerfil('uid-2'))!.uid, 'uid-2');
    });

    test('respeta el uid guardado en el documento', () async {
      servicio.documentos['uid-1'] = {'uid': 'otro-uid', 'nombre': 'Ana'};

      expect((await repositorio.obtenerPerfil('uid-1'))!.uid, 'otro-uid');
    });

    test('no modifica el documento del servicio', () async {
      servicio.documentos['uid-1'] = {'nombre': 'Ana'};

      await repositorio.obtenerPerfil('uid-1');

      expect(servicio.documentos['uid-1']!.containsKey('uid'), isFalse);
    });
  });

  test('cargarPerfilUsuario devuelve los datos crudos', () async {
    servicio.documentos['uid-1'] = {'nombre': 'Ana'};

    expect(await repositorio.cargarPerfilUsuario('uid-1'), {'nombre': 'Ana'});
  });

  test('guardarPerfil combina con lo existente', () async {
    servicio.documentos['uid-1'] = {'nombre': 'Ana', 'dni': '1'};

    await repositorio.guardarPerfil('uid-1', {'dni': '2'});

    expect(servicio.documentos['uid-1'], {'nombre': 'Ana', 'dni': '2'});
  });
}
