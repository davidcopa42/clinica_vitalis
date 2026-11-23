import '../../domain/models/borrador_sintomas.dart';
import '../../domain/models/borrador_turno.dart';

/// Contrato para guardar formularios a medio completar.
abstract class BorradorRepository {
  /// Devuelve el borrador de turno guardado (vacio si no hay).
  BorradorTurno obtenerBorradorTurno();

  /// Guarda el borrador de turno.
  Future<void> guardarBorradorTurno(BorradorTurno borrador);

  /// Elimina el borrador de turno.
  Future<void> eliminarBorradorTurno();

  /// Devuelve el borrador de sintomas guardado (vacio si no hay).
  BorradorSintomas obtenerBorradorSintomas();

  /// Guarda el borrador de sintomas.
  Future<void> guardarBorradorSintomas(BorradorSintomas borrador);

  /// Elimina el borrador de sintomas.
  Future<void> eliminarBorradorSintomas();
}
