import 'package:connectivity_plus/connectivity_plus.dart';

/// Define la interfaz o contrato para la conectividad
abstract class ServicioDeConectividad {
  Stream<bool> get cambios;
  Future<bool> hayRed();
}

/// Implementación usando el plugin connectivity_plus
bool _hayAlgunaRed(List<ConnectivityResult> resultados) =>
    resultados.any((r) => r != ConnectivityResult.none);

class ConectividadConPlus implements ServicioDeConectividad {
  final Connectivity _connectivity = Connectivity();

  @override
  Stream<bool> get cambios =>
      _connectivity.onConnectivityChanged.map(_hayAlgunaRed).distinct();

  @override
  Future<bool> hayRed() async =>
      _hayAlgunaRed(await _connectivity.checkConnectivity());
}