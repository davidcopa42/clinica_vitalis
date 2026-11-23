/// Registros clinicos simulados mientras no exista el sistema de la clinica.
class HistoriaClinicaEjemploService {
  HistoriaClinicaEjemploService({this.simularError = false});

  static const demoraSimulada = Duration(seconds: 1);

  /// Si es true, [obtenerRegistros] lanza una excepcion.
  final bool simularError;

  /// Devuelve los registros como mapas crudos tras una demora simulada.
  Future<List<Map<String, Object?>>> obtenerRegistros(
    String pacienteUid,
  ) async {
    await Future<void>.delayed(demoraSimulada);

    if (simularError) {
      throw Exception('No se pudieron cargar los registros clínicos.');
    }

    return const [
      {
        'tipo': 'analisis',
        'titulo': 'Hemograma completo',
        'fecha': '2026-10-20',
        'profesional': 'Dra. Laura Pérez',
        'detalle': 'Análisis de sangre de rutina.',
      },
      {
        'tipo': 'estudio',
        'titulo': 'Radiografía de tórax',
        'fecha': '2026-10-15',
        'profesional': 'Dr. Martín Gómez',
        'detalle': 'Estudio radiológico de tórax.',
      },
      {
        'tipo': 'receta',
        'titulo': 'Receta médica',
        'fecha': '2026-10-10',
        'profesional': 'Dra. Laura Pérez',
        'detalle': 'Registro de receta médica de ejemplo.',
      },
      {
        'tipo': 'analisis',
        'titulo': 'Análisis de glucemia',
        'fecha': '2026-09-25',
        'profesional': 'Dr. Martín Gómez',
        'detalle': 'Control de glucemia.',
      },
      {
        'tipo': 'estudio',
        'titulo': 'Electrocardiograma',
        'fecha': '2026-09-12',
        'profesional': 'Dra. Ana Torres',
        'detalle': 'Estudio de actividad eléctrica cardíaca.',
      },
      {
        'tipo': 'receta',
        'titulo': 'Receta médica anterior',
        'fecha': '2026-08-30',
        'profesional': 'Dra. Ana Torres',
        'detalle': 'Registro de receta médica de ejemplo.',
      },
      {
        'tipo': 'analisis',
        'titulo': 'Perfil lipídico',
        'fecha': '2026-08-15',
        'profesional': 'Dr. Martín Gómez',
        'detalle': 'Análisis de laboratorio de ejemplo.',
      },
    ];
  }
}
