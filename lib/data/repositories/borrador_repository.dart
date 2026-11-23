import '../../domain/models/borrador_sintomas.dart';
import '../../domain/models/borrador_turno.dart';

/// Contrato para guardar y recuperar los borradores de los formularios.
abstract class BorradorRepository {
  /// Borrador de Solicitar turno. Los campos sin guardar vienen en null.
  Future<BorradorTurno> obtenerBorradorTurno();

  /// Guarda el borrador. Los campos en null se borran.
  Future<void> guardarBorradorTurno(BorradorTurno borrador);

  Future<void> borrarBorradorTurno();

  /// Borrador de síntomas. Los campos sin guardar vienen en null.
  Future<BorradorSintomas> obtenerBorradorSintomas();

  /// Guarda el borrador. Los campos en null no se modifican.
  Future<void> guardarBorradorSintomas(BorradorSintomas borrador);

  Future<void> borrarBorradorSintomas();
}
