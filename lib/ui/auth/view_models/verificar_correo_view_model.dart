import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';

/// Estado y lógica de la pantalla Verificar correo.
///
/// Revisa periódicamente si el usuario ya verificó su correo y controla
/// la espera para volver a reenviar el enlace.
class VerificarCorreoViewModel extends ChangeNotifier {
  static const _intervaloVerificacion = Duration(seconds: 3);
  static const _segundosEsperaReenvio = 60;
  static const _intervaloCuentaRegresiva = Duration(seconds: 1);

  VerificarCorreoViewModel({
    required AuthRepository authRepository,
    required void Function() alVerificarCorreo,
  })  : _authRepo = authRepository,
        _alVerificarCorreo = alVerificarCorreo;

  final AuthRepository _authRepo;
  final void Function() _alVerificarCorreo;

  bool _puedeReenviar = true;
  int _segundosRestantes = 0;

  Timer? _timerReenvio;
  Timer? _timerVerificacionAutomatica;

  bool get puedeReenviar => _puedeReenviar;
  int get segundosRestantes => _segundosRestantes;

  /// Empieza a revisar cada 3 segundos si el correo ya fue verificado.
  void iniciarVerificacionAutomatica() {
    _timerVerificacionAutomatica = Timer.periodic(
      _intervaloVerificacion,
      (_) => comprobarVerificacion(),
    );
  }

  /// Recarga el usuario y, si ya verificó el correo, avisa y deja de revisar.
  ///
  /// Si la recarga falla, no avisa; el timer vuelve a intentar.
  Future<void> comprobarVerificacion() async {
    try {
      await _authRepo.recargarUsuario();
    } catch (_) {
      return;
    }

    if (_authRepo.correoVerificado) {
      _timerVerificacionAutomatica?.cancel();
      _alVerificarCorreo();
    }
  }

  /// Reenvía el enlace de verificación.
  ///
  /// Devuelve null si salió bien, o el mensaje de error para mostrar.
  Future<String?> reenviarCorreo() async {
    try {
      await _authRepo.enviarVerificacion();
      _iniciarTemporizadorReenvio();
      return null;
    } catch (error) {
      return 'Error al reenviar: $error';
    }
  }

  Future<void> cerrarSesion() async {
    await _authRepo.cerrarSesion();
  }

  void _iniciarTemporizadorReenvio() {
    _puedeReenviar = false;
    _segundosRestantes = _segundosEsperaReenvio;
    notifyListeners();

    _timerReenvio = Timer.periodic(_intervaloCuentaRegresiva, (timer) {
      if (_segundosRestantes > 0) {
        _segundosRestantes--;
      } else {
        _puedeReenviar = true;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timerReenvio?.cancel();
    _timerVerificacionAutomatica?.cancel();
    super.dispose();
  }
}
