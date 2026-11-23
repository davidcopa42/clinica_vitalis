import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Caracterizacion del modelo Turno', () {
    Turno crearTurno({int? id, EstadoTurno estado = EstadoTurno.confirmado}) {
      return Turno(
        id: id,
        pacienteUid: 'paciente-1',
        especialidad: 'Cardiología',
        profesional: 'Dr. Juan Pérez',
        fecha: DateTime(2026, 12, 1),
        horario: '09:20',
        estado: estado,
      );
    }

    test('el estado por defecto es confirmado y el id es null', () {
      final turno = Turno(
        pacienteUid: 'paciente-1',
        especialidad: 'Cardiología',
        profesional: 'Dr. Juan Pérez',
        fecha: DateTime(2026, 12, 1),
        horario: '09:20',
      );

      expect(turno.estado, EstadoTurno.confirmado);
      expect(turno.id, isNull);
    });

    test('fechaHora combina la fecha con el horario HH:mm', () {
      final turno = crearTurno();

      expect(turno.fechaHora, DateTime(2026, 12, 1, 9, 20));
    });

    test('toMap usa las columnas de SQLite y el nombre del estado', () {
      final mapa = crearTurno(id: 7).toMap();

      expect(mapa, {
        'id': 7,
        'paciente_uid': 'paciente-1',
        'especialidad': 'Cardiología',
        'profesional': 'Dr. Juan Pérez',
        'fecha': DateTime(2026, 12, 1).toIso8601String(),
        'horario': '09:20',
        'estado': 'confirmado',
      });
    });

    test('toMap guarda solo el dia de la fecha, sin la hora', () {
      final turno = Turno(
        pacienteUid: 'paciente-1',
        especialidad: 'Cardiología',
        profesional: 'Dr. Juan Pérez',
        fecha: DateTime(2026, 12, 1, 15, 45),
        horario: '09:20',
      );

      expect(turno.toMap()['fecha'], DateTime(2026, 12, 1).toIso8601String());
    });

    test('fromMap(toMap) conserva todos los datos', () {
      final original = crearTurno(id: 3, estado: EstadoTurno.cancelado);

      final reconstruido = Turno.fromMap(original.toMap());

      expect(reconstruido.id, original.id);
      expect(reconstruido.pacienteUid, original.pacienteUid);
      expect(reconstruido.especialidad, original.especialidad);
      expect(reconstruido.profesional, original.profesional);
      expect(reconstruido.fecha, original.fecha);
      expect(reconstruido.horario, original.horario);
      expect(reconstruido.estado, EstadoTurno.cancelado);
    });

    test('copyWith cambia id y estado y conserva el resto', () {
      final original = crearTurno();

      final copia = original.copyWith(id: 10, estado: EstadoTurno.cancelado);

      expect(copia.id, 10);
      expect(copia.estado, EstadoTurno.cancelado);
      expect(copia.pacienteUid, original.pacienteUid);
      expect(copia.especialidad, original.especialidad);
      expect(copia.profesional, original.profesional);
      expect(copia.fecha, original.fecha);
      expect(copia.horario, original.horario);
    });

    test('copyWith sin argumentos conserva id y estado', () {
      final original = crearTurno(id: 5, estado: EstadoTurno.cancelado);

      final copia = original.copyWith();

      expect(copia.id, 5);
      expect(copia.estado, EstadoTurno.cancelado);
    });
  });
}
