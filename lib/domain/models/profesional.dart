/// Profesional de la clinica que atiende turnos.
class Profesional {
  const Profesional({
    required this.nombre,
    required this.especialidad,
    required this.horarios,
  });

  /// Crea un profesional a partir de un mapa crudo.
  factory Profesional.fromMap(Map<String, Object?> mapa) {
    return Profesional(
      nombre: mapa['nombre'] as String,
      especialidad: mapa['especialidad'] as String,
      horarios: List<String>.from(mapa['horarios'] as List),
    );
  }

  final String nombre;
  final String especialidad;

  /// Horarios en los que atiende, con formato 'HH:mm'.
  final List<String> horarios;

  /// Convierte el profesional en un mapa crudo.
  Map<String, Object?> toMap() {
    return {
      'nombre': nombre,
      'especialidad': especialidad,
      'horarios': horarios,
    };
  }
}
