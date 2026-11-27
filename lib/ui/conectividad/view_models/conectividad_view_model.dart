import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/repositories/conectividad_repository.dart';

class ConectividadViewModel extends ChangeNotifier {
  final ConectividadRepository _repositorio;
  StreamSubscription<bool>? _suscripcion;
  bool _hayConexion = true;

  ConectividadViewModel({required ConectividadRepository repositorio})
      : _repositorio = repositorio {
    _suscripcion = _repositorio.cambiosDeConexion.listen(_actualizar);

    _repositorio.verificarConexion().then(_actualizar);
  }

  bool get hayConexion => _hayConexion;

  void _actualizar(bool conectado) {
    if (conectado == _hayConexion) return;
    _hayConexion = conectado;
    notifyListeners();
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }
}
