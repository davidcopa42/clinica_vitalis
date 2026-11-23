import 'package:clinica_vitalis/domain/models/registro_clinico.dart';

/// Contrato para obtener la historia clínica de un paciente.
abstract class HistoriaClinicaRepository {
  /// Registros clínicos del paciente, del más reciente al más antiguo.
  Future<List<RegistroClinico>> obtenerRegistros(String pacienteUid);
}
