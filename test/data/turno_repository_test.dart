import 'package:clinica_vitalis/data/repositories/turno_repositorio_local.dart';
import 'package:clinica_vitalis/data/repositories/turno_repository.dart';
import 'package:clinica_vitalis/data/services/base_datos_service.dart';
import 'package:clinica_vitalis/data/services/datos_ejemplo.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:flutter_test/flutter_test.dart';

/// Base de datos en memoria que imita a [BaseDatosService].
///
/// Interpreta condiciones del tipo `columna = ? AND columna = ?`.
class FakeBaseDatosService implements BaseDatosService {
  final List<Map<String, Object?>> filas = [];
  int _proximoId = 1;

  @override
  Future<int> insertar(Map<String, Object?> datos) async {
    final id = _proximoId++;
    filas.add({...datos, 'id': id});
    return id;
  }

  @override
  Future<List<Map<String, Object?>>> consultar({
    String? where,
    List<Object?>? whereArgs,
  }) async {
    if (where == null) return List.of(filas);

    final columnas = RegExp(r'(\w+) = \?')
        .allMatches(where)
        .map((coincidencia) => coincidencia.group(1)!)
        .toList();

    return filas.where((fila) {
      for (var indice = 0; indice < columnas.length; indice++) {
        if (fila[columnas[indice]] != whereArgs![indice]) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<void> actualizar(int id, Map<String, Object?> datos) async {
    final fila = filas.firstWhere((fila) => fila['id'] == id);
    fila.addAll(datos);
  }
}

void main() {
  // Dr. Juan Pérez (Cardiología) atiende 08:00, 08:40, 09:20 y 10:00.
  const profesional = 'Dr. Juan Pérez';
  const horariosDelProfesional = ['08:00', '08:40', '09:20', '10:00'];

  late FakeBaseDatosService baseDatos;
  late TurnoRepositorioLocal repositorio;

  final hoy = DateTime.now();
  final fechaFutura = DateTime(hoy.year, hoy.month, hoy.day + 30);
  final fechaPasada = DateTime(hoy.year, hoy.month, hoy.day - 1);

  Turno crearTurno({
    String pacienteUid = 'paciente-1',
    DateTime? fecha,
    String horario = '09:20',
  }) {
    return Turno(
      pacienteUid: pacienteUid,
      especialidad: 'Cardiología',
      profesional: profesional,
      fecha: fecha ?? fechaFutura,
      horario: horario,
    );
  }

  setUp(() {
    baseDatos = FakeBaseDatosService();
    repositorio = TurnoRepositorioLocal(baseDatos: baseDatos);
  });

  group('obtenerProfesionales', () {
    test('devuelve los profesionales de ejemplo', () async {
      expect(await repositorio.obtenerProfesionales(), profesionalesDeEjemplo);
    });
  });

  group('horariosDisponibles', () {
    test('devuelve vacio si el profesional no existe', () async {
      final horarios =
          await repositorio.horariosDisponibles('Dr. Inexistente', fechaFutura);

      expect(horarios, isEmpty);
    });

    test('sin reservas devuelve todos los horarios del profesional', () async {
      final horarios =
          await repositorio.horariosDisponibles(profesional, fechaFutura);

      expect(horarios, horariosDelProfesional);
    });

    test('excluye horarios reservados por cualquier paciente', () async {
      await baseDatos.insertar(
        crearTurno(pacienteUid: 'otro-paciente', horario: '08:40').toMap(),
      );

      final horarios =
          await repositorio.horariosDisponibles(profesional, fechaFutura);

      expect(horarios, ['08:00', '09:20', '10:00']);
    });

    test('un turno cancelado libera su horario', () async {
      final id = await baseDatos.insertar(crearTurno(horario: '08:40').toMap());
      await repositorio.cancelarTurno(id);

      final horarios =
          await repositorio.horariosDisponibles(profesional, fechaFutura);

      expect(horarios, horariosDelProfesional);
    });

    test('las reservas de otro dia no afectan', () async {
      final otroDia = DateTime(hoy.year, hoy.month, hoy.day + 31);
      await baseDatos.insertar(
        crearTurno(fecha: otroDia, horario: '08:40').toMap(),
      );

      final horarios =
          await repositorio.horariosDisponibles(profesional, fechaFutura);

      expect(horarios, horariosDelProfesional);
    });

    test('en una fecha pasada no hay horarios', () async {
      final horarios =
          await repositorio.horariosDisponibles(profesional, fechaPasada);

      expect(horarios, isEmpty);
    });
  });

  group('guardarTurno', () {
    test('guarda el turno y lo devuelve con el id asignado', () async {
      final guardado = await repositorio.guardarTurno(crearTurno());

      expect(guardado.id, 1);
      expect(guardado.horario, '09:20');
      expect(baseDatos.filas, hasLength(1));
      expect(baseDatos.filas.single['estado'], 'confirmado');
    });

    test('lanza TurnoNoDisponibleException si el horario esta ocupado',
        () async {
      await repositorio.guardarTurno(crearTurno(pacienteUid: 'otro-paciente'));

      await expectLater(
        repositorio.guardarTurno(crearTurno()),
        throwsA(isA<TurnoNoDisponibleException>()),
      );
      expect(baseDatos.filas, hasLength(1));
    });

    test('lanza TurnoNoDisponibleException si el horario no es del profesional',
        () async {
      await expectLater(
        repositorio.guardarTurno(crearTurno(horario: '23:00')),
        throwsA(isA<TurnoNoDisponibleException>()),
      );
    });

    test('lanza TurnoNoDisponibleException si la fecha ya paso', () async {
      await expectLater(
        repositorio.guardarTurno(crearTurno(fecha: fechaPasada)),
        throwsA(isA<TurnoNoDisponibleException>()),
      );
    });
  });

  group('cancelarTurno', () {
    test('marca el turno como cancelado sin borrarlo', () async {
      final guardado = await repositorio.guardarTurno(crearTurno());

      await repositorio.cancelarTurno(guardado.id!);

      expect(baseDatos.filas, hasLength(1));
      expect(baseDatos.filas.single['estado'], 'cancelado');
    });
  });

  group('procesarTurnos', () {
    Map<String, Object?> fila(int id, DateTime fecha, String horario) {
      return crearTurno(fecha: fecha, horario: horario)
          .copyWith(id: id)
          .toMap();
    }

    test('descarta los turnos pasados y ordena del mas cercano al mas lejano',
        () {
      final ahora = DateTime(2026, 11, 18, 12);

      final resultado = procesarTurnos((
        filas: [
          fila(1, DateTime(2026, 11, 20), '10:00'),
          fila(2, DateTime(2026, 11, 18), '09:20'),
          fila(3, DateTime(2026, 11, 18), '15:30'),
          fila(4, DateTime(2026, 11, 19), '08:00'),
        ],
        ahora: ahora,
      ));

      expect(resultado.map((turno) => turno.id), [3, 4, 1]);
    });
  });

  group('obtenerTurnos', () {
    test('devuelve solo turnos confirmados y futuros del paciente, ordenados',
        () async {
      final masLejano = DateTime(hoy.year, hoy.month, hoy.day + 40);
      await baseDatos.insertar(crearTurno(fecha: masLejano).toMap());
      await baseDatos.insertar(crearTurno(horario: '10:00').toMap());
      await baseDatos.insertar(crearTurno(horario: '08:00').toMap());
      await baseDatos.insertar(
        crearTurno(pacienteUid: 'otro-paciente', horario: '08:40').toMap(),
      );
      await baseDatos.insertar(crearTurno(fecha: fechaPasada).toMap());
      final idCancelado =
          await baseDatos.insertar(crearTurno(horario: '09:20').toMap());
      await repositorio.cancelarTurno(idCancelado);

      final turnos = await repositorio.obtenerTurnos('paciente-1');

      expect(
        turnos.map((turno) => turno.fechaHora).toList(),
        [
          DateTime(fechaFutura.year, fechaFutura.month, fechaFutura.day, 8),
          DateTime(fechaFutura.year, fechaFutura.month, fechaFutura.day, 10),
          DateTime(masLejano.year, masLejano.month, masLejano.day, 9, 20),
        ],
      );
    });

    test('sin turnos devuelve una lista vacia', () async {
      expect(await repositorio.obtenerTurnos('paciente-1'), isEmpty);
    });
  });
}
