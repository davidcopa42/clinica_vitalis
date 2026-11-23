/// Contrato para conocer el estado de la conexión a internet.
abstract class ConectividadRepository {
  /// Emite true o false cada vez que cambia la conexión.
  Stream<bool> get cambiosDeConexion;

  /// Consulta si en este momento hay conexión.
  Future<bool> verificarConexion();
}
