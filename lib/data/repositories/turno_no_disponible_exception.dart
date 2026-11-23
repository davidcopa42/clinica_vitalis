/// Se lanza cuando se intenta reservar un horario que ya no esta libre.
class TurnoNoDisponibleException implements Exception {
  const TurnoNoDisponibleException();

  @override
  String toString() => 'Ese horario ya no está disponible.';
}
