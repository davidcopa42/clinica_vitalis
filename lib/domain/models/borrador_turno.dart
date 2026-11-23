/// Datos a medio cargar de la pantalla Solicitar turno.
///
/// Cada campo es null si el paciente todavía no lo eligió.
class BorradorTurno {
  const BorradorTurno({
    this.especialidad,
    this.profesional,
    this.fecha,
    this.horario,
  });

  final String? especialidad;
  final String? profesional;
  final DateTime? fecha;

  /// Horario con formato 'HH:mm'.
  final String? horario;
}
