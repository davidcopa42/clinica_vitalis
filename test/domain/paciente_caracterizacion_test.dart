import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Caracterizacion de Paciente.fromMap', () {
    test('un mapa vacio produce textos vacios y opcionales en null', () {
      final paciente = Paciente.fromMap(const {});

      expect(paciente.uid, '');
      expect(paciente.nombre, '');
      expect(paciente.apellido, '');
      expect(paciente.correo, '');
      expect(paciente.telefono, '');
      expect(paciente.dni, '');
      expect(paciente.fechaNacimiento, isNull);
      expect(paciente.obraSocial, isNull);
      expect(paciente.numeroAfiliado, isNull);
      expect(paciente.fotoUrl, isNull);
      expect(paciente.perfilCompleto, isFalse);
    });

    test('nombreCompleto une nombre y apellido con un espacio', () {
      const paciente = Paciente(
        uid: '1',
        nombre: 'Ana',
        apellido: 'López',
        correo: 'ana@test.com',
      );

      expect(paciente.nombreCompleto, 'Ana López');
    });

    // Bug conocido (Fase D, bug 1): el registro y el primer login con Google
    // guardan fechaNacimiento como '' y fromMap no lo tolera.
    test('BUG CONOCIDO: fechaNacimiento vacia lanza FormatException', () {
      expect(
        () => Paciente.fromMap(const {'nombre': 'Ana', 'fechaNacimiento': ''}),
        throwsFormatException,
      );
    });

    // Bug conocido (Fase D, bug 2): el registro guarda la clave 'photoUrl'
    // pero el modelo lee 'fotoUrl'.
    test('BUG CONOCIDO: la clave photoUrl no se lee como fotoUrl', () {
      final paciente = Paciente.fromMap(
        const {'photoUrl': 'https://foto.com/img.png'},
      );

      expect(paciente.fotoUrl, isNull);
    });
  });
}
