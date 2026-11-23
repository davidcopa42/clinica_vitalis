import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/repositories/conectividad_repository.dart';

class ConectividadViewModel extends ChangeNotifier {
  final ConectividadRepository _repositorio;
  StreamSubscription<bool>? _suscripcion;
  bool _hayConexion = true;

  ConectividadViewModel({required ConectividadRepository repositorio})
      : _repositorio = repositorio {
    // 1. Nos suscribimos a los cambios del stream
    _suscripcion = _repositorio.cambiosDeConexion.listen(_actualizar);

    // 2. Verificamos el estado actual de la red de inmediato
    _repositorio.verificarConexion().then(_actualizar);
  }

  bool get hayConexion => _hayConexion;

  void _actualizar(bool hay) {
    if (hay == _hayConexion) return;
    _hayConexion = hay;
    notifyListeners(); // Notifica a la interfaz para que redibuje el aviso si cambia
  }

  @override
  void dispose() {
    // 3. OBLIGATORIO: cancelamos la suscripción para evitar fugas de memoria (Memory Leaks)
    _suscripcion?.cancel();
    super.dispose();
  }
}
