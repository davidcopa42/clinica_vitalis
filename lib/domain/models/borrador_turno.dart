/// Datos parciales de un turno que el paciente todavia no confirmo.
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
  final String? horario;

  /// Indica si el borrador no tiene ningun dato cargado.
  bool get estaVacio =>
      especialidad == null &&
      profesional == null &&
      fecha == null &&
      horario == null;
}
