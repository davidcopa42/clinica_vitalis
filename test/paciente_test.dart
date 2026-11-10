import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pruebas del modelo Paciente', () {
    test('toMap y fromMap deben conservar los datos exactamente iguales', () {
      final fecha = DateTime(1995, 5, 12);
      final pacienteOriginal = Paciente(
        uid: '12345',
        nombre: 'Josué',
        apellido: 'Flores',
        correo: 'josue@test.com',
        telefono: '2611234567',
        dni: '12345678',
        fechaNacimiento: fecha,
        obraSocial: 'OSDE',
        numeroAfiliado: '987654',
        fotoUrl: 'https://foto.com/img.png',
      );

      final mapa = pacienteOriginal.toMap();
      final pacienteReconstruido = Paciente.fromMap(mapa);

      expect(pacienteReconstruido.uid, pacienteOriginal.uid);
      expect(pacienteReconstruido.nombre, pacienteOriginal.nombre);
      expect(pacienteReconstruido.apellido, pacienteOriginal.apellido);
      expect(pacienteReconstruido.correo, pacienteOriginal.correo);
      expect(pacienteReconstruido.telefono, pacienteOriginal.telefono);
      expect(pacienteReconstruido.dni, pacienteOriginal.dni);
      expect(pacienteReconstruido.fechaNacimiento,
          pacienteOriginal.fechaNacimiento);
      expect(pacienteReconstruido.obraSocial, pacienteOriginal.obraSocial);
      expect(
          pacienteReconstruido.numeroAfiliado, pacienteOriginal.numeroAfiliado);
      expect(pacienteReconstruido.fotoUrl, pacienteOriginal.fotoUrl);
    });

    test('perfilCompleto debe ser false si falta algún dato obligatorio', () {
      const pacienteIncompleto = Paciente(
        uid: '123',
        nombre: '',
        apellido: 'Flores',
        correo: 'test@test.com',
      );

      expect(pacienteIncompleto.perfilCompleto, isFalse);
    });

    test(
        'perfilCompleto debe ser true si todos los datos obligatorios están llenos',
        () {
      final pacienteCompleto = Paciente(
        uid: '123',
        nombre: 'Josué',
        apellido: 'Flores',
        correo: 'test@test.com',
        telefono: '2611234567',
        dni: '12345678',
        fechaNacimiento: DateTime(2000, 1, 1),
      );

      expect(pacienteCompleto.perfilCompleto, isTrue);
    });
  });
}
