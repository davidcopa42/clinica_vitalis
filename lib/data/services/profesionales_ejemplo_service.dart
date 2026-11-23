/// Profesionales de ejemplo mientras no exista el sistema de la clinica.
class ProfesionalesEjemploService {
  static const List<Map<String, Object?>> _profesionales = [
    {
      'nombre': 'Dra. Ana López',
      'especialidad': 'Clínica Médica',
      'horarios': ['09:00', '09:30', '10:00', '10:30', '11:00'],
    },
    {
      'nombre': 'Dr. Roberto Díaz',
      'especialidad': 'Clínica Médica',
      'horarios': ['14:00', '14:30', '15:00', '15:30', '16:00'],
    },
    {
      'nombre': 'Dr. Juan Pérez',
      'especialidad': 'Cardiología',
      'horarios': ['08:00', '08:40', '09:20', '10:00'],
    },
    {
      'nombre': 'Dra. María Gómez',
      'especialidad': 'Pediatría',
      'horarios': ['10:00', '10:20', '10:40', '11:00', '11:20', '11:40'],
    },
    {
      'nombre': 'Dr. Carlos Ruiz',
      'especialidad': 'Dermatología',
      'horarios': ['16:00', '16:30', '17:00'],
    },
  ];

  /// Devuelve los profesionales como mapas crudos.
  Future<List<Map<String, Object?>>> obtenerProfesionales() async =>
      _profesionales;
}
