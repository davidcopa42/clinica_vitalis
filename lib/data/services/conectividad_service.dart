import 'package:connectivity_plus/connectivity_plus.dart';

/// Acceso directo al plugin connectivity_plus.
class ConectividadService {
  ConectividadService({required Connectivity conectividad})
      : _conectividad = conectividad;

  final Connectivity _conectividad;

  /// Emite los tipos de red disponibles cada vez que cambian.
  Stream<List<ConnectivityResult>> get cambios =>
      _conectividad.onConnectivityChanged;

  /// Devuelve los tipos de red disponibles en este momento.
  Future<List<ConnectivityResult>> consultarEstado() =>
      _conectividad.checkConnectivity();
}
