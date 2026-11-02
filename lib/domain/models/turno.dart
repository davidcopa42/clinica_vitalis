/// Estado de un turno.
enum EstadoTurno { confirmado, cancelado }

/// Turno médico reservado por un paciente.
class Turno {
  const Turno({
    this.id,
    required this.pacienteUid,
    required this.especialidad,
    required this.profesional,
    required this.fecha,
    required this.horario,
    this.estado = EstadoTurno.confirmado,
  });

  /// Identificador en la base de datos. Es null hasta que se guarda.
  final int? id;

  /// Identificador del paciente dueño del turno.
  final String pacienteUid;

  final String especialidad;
  final String profesional;

  /// Día del turno (la hora está en [horario]).
  final DateTime fecha;

  /// Hora del turno con formato 'HH:mm', por ejemplo '09:30'.
  final String horario;

  final EstadoTurno estado;

  /// Fecha y hora juntas, para ordenar y programar el recordatorio.
  DateTime get fechaHora {
    final partes = horario.split(':');
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      int.parse(partes[0]),
      int.parse(partes[1]),
    );
  }

  /// Devuelve una copia con el id o el estado cambiados.
  Turno copyWith({int? id, EstadoTurno? estado}) {
    return Turno(
      id: id ?? this.id,
      pacienteUid: pacienteUid,
      especialidad: especialidad,
      profesional: profesional,
      fecha: fecha,
      horario: horario,
      estado: estado ?? this.estado,
    );
  }

  /// Convierte el turno en un mapa para guardarlo en la base de datos.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'paciente_uid': pacienteUid,
      'especialidad': especialidad,
      'profesional': profesional,
      'fecha': DateTime(fecha.year, fecha.month, fecha.day).toIso8601String(),
      'horario': horario,
      'estado': estado.name,
    };
  }

  /// Crea un turno a partir de un mapa leído de la base de datos.
  factory Turno.fromMap(Map<String, Object?> mapa) {
    return Turno(
      id: mapa['id'] as int?,
      pacienteUid: mapa['paciente_uid'] as String,
      especialidad: mapa['especialidad'] as String,
      profesional: mapa['profesional'] as String,
      fecha: DateTime.parse(mapa['fecha'] as String),
      horario: mapa['horario'] as String,
      estado: EstadoTurno.values.byName(mapa['estado'] as String),
    );
  }
}