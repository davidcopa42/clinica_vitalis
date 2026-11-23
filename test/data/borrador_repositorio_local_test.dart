import 'package:clinica_vitalis/data/repositories/borrador_repositorio_local.dart';
import 'package:clinica_vitalis/data/services/borrador_service.dart';
import 'package:clinica_vitalis/domain/models/borrador_sintomas.dart';
import 'package:clinica_vitalis/domain/models/borrador_turno.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BorradorRepositorioLocal repositorio;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repositorio = BorradorRepositorioLocal(borradorService: BorradorService());
  });

  group('borrador de turno', () {
    test('sin nada guardado todos los campos vienen en null', () async {
      final borrador = await repositorio.obtenerBorradorTurno();

      expect(borrador.especialidad, isNull);
      expect(borrador.profesional, isNull);
      expect(borrador.fecha, isNull);
      expect(borrador.horario, isNull);
    });

    test('guarda con las claves borrador_* y se recupera igual', () async {
      final fecha = DateTime(2030, 3, 15);
      await repositorio.guardarBorradorTurno(
        BorradorTurno(
          especialidad: 'Cardiología',
          profesional: 'Dr. Juan Pérez',
          fecha: fecha,
          horario: '08:40',
        ),
      );

      final preferencias = await SharedPreferences.getInstance();
      expect(preferencias.getString('borrador_especialidad'), 'Cardiología');
      expect(preferencias.getString('borrador_fecha'), fecha.toIso8601String());

      final borrador = await repositorio.obtenerBorradorTurno();
      expect(borrador.especialidad, 'Cardiología');
      expect(borrador.profesional, 'Dr. Juan Pérez');
      expect(borrador.fecha, fecha);
      expect(borrador.horario, '08:40');
    });

    test('una fecha guardada invalida se ignora y el resto se recupera',
        () async {
      SharedPreferences.setMockInitialValues({
        'borrador_especialidad': 'Cardiología',
        'borrador_fecha': 'no-es-una-fecha',
        'borrador_horario': '08:40',
      });

      final borrador = await repositorio.obtenerBorradorTurno();

      expect(borrador.especialidad, 'Cardiología');
      expect(borrador.fecha, isNull);
      expect(borrador.horario, '08:40');
    });

    test('un campo en null borra su clave', () async {
      SharedPreferences.setMockInitialValues({
        'borrador_especialidad': 'Cardiología',
        'borrador_horario': '08:40',
      });

      await repositorio.guardarBorradorTurno(
        const BorradorTurno(especialidad: 'Pediatría'),
      );

      final preferencias = await SharedPreferences.getInstance();
      expect(preferencias.getString('borrador_especialidad'), 'Pediatría');
      expect(preferencias.containsKey('borrador_horario'), isFalse);
    });

    test('borrarBorradorTurno quita las cuatro claves', () async {
      SharedPreferences.setMockInitialValues({
        'borrador_especialidad': 'Cardiología',
        'borrador_profesional': 'Dr. Juan Pérez',
        'borrador_fecha': DateTime(2030).toIso8601String(),
        'borrador_horario': '08:40',
      });

      await repositorio.borrarBorradorTurno();

      final preferencias = await SharedPreferences.getInstance();
      expect(preferencias.getKeys(), isEmpty);
    });
  });

  group('borrador de sintomas', () {
    test('sin nada guardado todos los campos vienen en null', () async {
      final borrador = await repositorio.obtenerBorradorSintomas();

      expect(borrador.sintomas, isNull);
      expect(borrador.descripcion, isNull);
      expect(borrador.duracion, isNull);
      expect(borrador.intensidad, isNull);
    });

    test('guarda y recupera los cuatro campos', () async {
      await repositorio.guardarBorradorSintomas(
        const BorradorSintomas(
          sintomas: ['Fiebre', 'Tos'],
          descripcion: 'Seca',
          duracion: 'Ayer',
          intensidad: 4,
        ),
      );

      final borrador = await repositorio.obtenerBorradorSintomas();
      expect(borrador.sintomas, ['Fiebre', 'Tos']);
      expect(borrador.descripcion, 'Seca');
      expect(borrador.duracion, 'Ayer');
      expect(borrador.intensidad, 4);
    });

    test('un campo en null no modifica lo guardado', () async {
      SharedPreferences.setMockInitialValues({
        'borrador_sintomas_desc': 'Anterior',
      });

      await repositorio.guardarBorradorSintomas(
        const BorradorSintomas(duracion: 'Hoy'),
      );

      final preferencias = await SharedPreferences.getInstance();
      expect(preferencias.getString('borrador_sintomas_desc'), 'Anterior');
      expect(preferencias.getString('borrador_sintomas_duracion'), 'Hoy');
    });

    test('borrarBorradorSintomas quita las cuatro claves', () async {
      SharedPreferences.setMockInitialValues({
        'borrador_sintomas_lista': ['Tos'],
        'borrador_sintomas_desc': 'Seca',
        'borrador_sintomas_duracion': 'Ayer',
        'borrador_sintomas_intensidad': 4.0,
      });

      await repositorio.borrarBorradorSintomas();

      final preferencias = await SharedPreferences.getInstance();
      expect(preferencias.getKeys(), isEmpty);
    });
  });
}
