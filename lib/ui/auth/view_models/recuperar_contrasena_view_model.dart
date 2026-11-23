import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../core/estado_carga.dart';

/// Estado y comandos de la pantalla para recuperar la contrasena.
class RecuperarContrasenaViewModel extends ChangeNotifier {
  RecuperarContrasenaViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  /// Mensaje neutro: no revela si el correo tiene una cuenta.
  static const mensajeEnviado =
      'Si el correo está registrado, te llegará un enlace';

  final AuthRepository _authRepository;

  EstadoCarga _estado = EstadoCarga.inicial;

  bool get estaCargando => _estado == EstadoCarga.cargando;
  bool get fueEnviado => _estado == EstadoCarga.exito;

  /// Vuelve al estado inicial (por ejemplo, al abrir la pantalla).
  void reiniciar() {
    _estado = EstadoCarga.inicial;
    notifyListeners();
  }

  /// Pide el enlace de recuperacion para [correo].
  ///
  /// Los errores se ignoran a proposito para no revelar que correos
  /// tienen cuenta; siempre se informa [mensajeEnviado].
  Future<void> enviarEnlace(String correo) async {
    _estado = EstadoCarga.cargando;
    notifyListeners();

    try {
      await _authRepository.recuperarContrasena(correo);
    } catch (_) {
      // Ver comentario del metodo.
    } finally {
      _estado = EstadoCarga.exito;
      notifyListeners();
    }
  }
}
