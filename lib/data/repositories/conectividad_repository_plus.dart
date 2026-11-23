import 'package:connectivity_plus/connectivity_plus.dart';

import '../services/conectividad_service.dart';
import 'conectividad_repository.dart';

/// Implementacion de [ConectividadRepository] sobre connectivity_plus.
class ConectividadRepositoryPlus implements ConectividadRepository {
  ConectividadRepositoryPlus({
    required ConectividadService conectividadService,
  }) : _servicio = conectividadService;

  final ConectividadService _servicio;

  @override
  Stream<bool> get cambiosDeConexion =>
      _servicio.cambios.map(_hayAlgunaRed).distinct();

  @override
  Future<bool> hayConexion() async =>
      _hayAlgunaRed(await _servicio.consultarEstado());

  bool _hayAlgunaRed(List<ConnectivityResult> redes) =>
      redes.any((red) => red != ConnectivityResult.none);
}
