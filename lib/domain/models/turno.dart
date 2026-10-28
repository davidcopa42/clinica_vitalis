class Turno {
  const Turno({
    required this.especialidad,
    required this.profesional,
    required this.fecha,
    required this.horario,
  });

  final String especialidad;
  final String profesional;
  final DateTime fecha;
  final String horario;
}