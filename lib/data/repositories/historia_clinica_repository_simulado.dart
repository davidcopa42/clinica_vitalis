import '../../domain/models/registro_clinico.dart';
import '../services/historia_clinica_ejemplo_service.dart';
import 'historia_clinica_repository.dart';

/// Implementacion de [HistoriaClinicaRepository] con datos de ejemplo.
///
/// En el futuro se conectara con el sistema interno de la clinica.
class HistoriaClinicaRepositorySimulado implements HistoriaClinicaRepository {
  HistoriaClinicaRepositorySimulado({
    required HistoriaClinicaEjemploService historiaClinicaService,
  }) : _servicio = historiaClinicaService;

  final HistoriaClinicaEjemploService _servicio;

  @override
  Future<List<RegistroClinico>> obtenerRegistros(String pacienteUid) async {
    final filas = await _servicio.obtenerRegistros(pacienteUid);
    return filas.map(RegistroClinico.fromMap).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }
}
