import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/conectividad_repository.dart';

/// Expone si hay conexion a internet para mostrar un aviso.
class ConectividadViewModel extends ChangeNotifier {
  ConectividadViewModel({
    required ConectividadRepository conectividadRepository,
  }) : _repositorio = conectividadRepository {
    _suscripcion = _repositorio.cambiosDeConexion.listen(_actualizar);
    _repositorio.hayConexion().then(_actualizar);
  }

  final ConectividadRepository _repositorio;
  late final StreamSubscription<bool> _suscripcion;
  bool _hayConexion = true;

  bool get hayConexion => _hayConexion;

  void _actualizar(bool hayConexion) {
    if (hayConexion == _hayConexion) return;
    _hayConexion = hayConexion;
    notifyListeners();
  }

  @override
  void dispose() {
    _suscripcion.cancel();
    super.dispose();
  }
}
