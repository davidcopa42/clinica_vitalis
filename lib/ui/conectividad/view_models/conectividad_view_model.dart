import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/services/conectividad_service.dart';

class ConectividadViewModel extends ChangeNotifier {
  final ServicioDeConectividad _servicio;
  StreamSubscription<bool>? _suscripcion;
  bool _hayConexion = true;

  ConectividadViewModel({required ServicioDeConectividad servicio}) : _servicio = servicio {
    // 1. Nos suscribimos a los cambios del stream
    _suscripcion = _servicio.cambios.listen(_actualizar);

    // 2. Verificamos el estado actual de la red de inmediato
    _servicio.hayRed().then(_actualizar);
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