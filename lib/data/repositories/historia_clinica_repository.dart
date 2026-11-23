import '../../domain/models/registro_clinico.dart';

/// Contrato para obtener la historia clinica del paciente.
abstract class HistoriaClinicaRepository {
  /// Registros del paciente, del mas reciente al mas antiguo.
  Future<List<RegistroClinico>> obtenerRegistros(String pacienteUid);
}
