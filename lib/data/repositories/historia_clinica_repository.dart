import 'package:clinica_vitalis/domain/models/registro_clinico.dart';

/// Proporciona los registros clínicos simulados del paciente.
class HistoriaClinicaRepository {
  HistoriaClinicaRepository({
    this.simularError = false,
  });

  final bool simularError;

  /// Obtiene entre 6 y 8 registros de ejemplo.
  ///
  /// En el futuro se conectará con el sistema interno de la clínica.
  Future<List<RegistroClinico>> obtenerRegistros(
    String pacienteUid,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    if (simularError) {
      throw Exception('No se pudieron cargar los registros clínicos.');
    }

    final registros = <RegistroClinico>[
      RegistroClinico(
        tipo: TipoRegistro.analisis,
        titulo: 'Hemograma completo',
        fecha: DateTime(2026, 10, 20),
        profesional: 'Dra. Laura Pérez',
        detalle: 'Análisis de sangre de rutina.',
      ),
      RegistroClinico(
        tipo: TipoRegistro.estudio,
        titulo: 'Radiografía de tórax',
        fecha: DateTime(2026, 10, 15),
        profesional: 'Dr. Martín Gómez',
        detalle: 'Estudio radiológico de tórax.',
      ),
      RegistroClinico(
        tipo: TipoRegistro.receta,
        titulo: 'Receta médica',
        fecha: DateTime(2026, 10, 10),
        profesional: 'Dra. Laura Pérez',
        detalle: 'Registro de receta médica de ejemplo.',
      ),
      RegistroClinico(
        tipo: TipoRegistro.analisis,
        titulo: 'Análisis de glucemia',
        fecha: DateTime(2026, 9, 25),
        profesional: 'Dr. Martín Gómez',
        detalle: 'Control de glucemia.',
      ),
      RegistroClinico(
        tipo: TipoRegistro.estudio,
        titulo: 'Electrocardiograma',
        fecha: DateTime(2026, 9, 12),
        profesional: 'Dra. Ana Torres',
        detalle: 'Estudio de actividad eléctrica cardíaca.',
      ),
      RegistroClinico(
        tipo: TipoRegistro.receta,
        titulo: 'Receta médica anterior',
        fecha: DateTime(2026, 8, 30),
        profesional: 'Dra. Ana Torres',
        detalle: 'Registro de receta médica de ejemplo.',
      ),
      RegistroClinico(
        tipo: TipoRegistro.analisis,
        titulo: 'Perfil lipídico',
        fecha: DateTime(2026, 8, 15),
        profesional: 'Dr. Martín Gómez',
        detalle: 'Análisis de laboratorio de ejemplo.',
      ),
    ];

    registros.sort(
      (a, b) => b.fecha.compareTo(a.fecha),
    );

    return registros;
  }
}
