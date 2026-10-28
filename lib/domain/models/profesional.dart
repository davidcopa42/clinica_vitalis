/// Profesional de la clínica que atiende turnos.
class Profesional {
  const Profesional({
    required this.nombre,
    required this.especialidad,
    required this.horarios,
  });

  final String nombre;
  final String especialidad;

  /// Horarios en los que atiende, con formato 'HH:mm'.
  final List<String> horarios;
}