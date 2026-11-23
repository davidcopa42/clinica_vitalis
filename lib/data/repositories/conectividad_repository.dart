/// Contrato para conocer el estado de la conexion a internet.
abstract class ConectividadRepository {
  /// Emite true o false cada vez que cambia la conexion.
  Stream<bool> get cambiosDeConexion;

  /// Indica si en este momento hay alguna red disponible.
  Future<bool> hayConexion();
}
