import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';

/// Estado y comandos de la pantalla que espera la verificacion del correo.
class VerificarCorreoViewModel extends ChangeNotifier {
  VerificarCorreoViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  static const intervaloComprobacion = Duration(seconds: 3);
  static const esperaReenvio = 60;
  static const _unSegundo = Duration(seconds: 1);

  final AuthRepository _authRepository;

  Timer? _temporizadorComprobacion;
  Timer? _temporizadorReenvio;
  int _segundosRestantes = 0;
  bool _estaVerificado = false;
  String? _aviso;

  bool get estaVerificado => _estaVerificado;
  bool get puedeReenviar => _segundosRestantes == 0;

  /// Mensaje para mostrar una sola vez; la vista llama a [limpiarAviso].
  String? get aviso => _aviso;

  String get textoBotonReenvio => puedeReenviar
      ? 'Reenviar correo'
      : 'Reenviar disponible en ${_segundosRestantes}s';

  /// Empieza a comprobar periodicamente si el correo ya fue verificado.
  void iniciarComprobacion() {
    _estaVerificado = false;
    _temporizadorComprobacion?.cancel();
    _temporizadorComprobacion = Timer.periodic(
      intervaloComprobacion,
      (_) => comprobarVerificacion(),
    );
  }

  /// Detiene todos los temporizadores.
  void detenerComprobacion() {
    _temporizadorComprobacion?.cancel();
    _temporizadorReenvio?.cancel();
    _segundosRestantes = 0;
  }

  /// Relee el usuario y marca [estaVerificado] si ya verifico el correo.
  Future<void> comprobarVerificacion() async {
    try {
      await _authRepository.recargarUsuario();
    } catch (_) {
      return;
    }
    if (!_authRepository.correoVerificado) return;

    _temporizadorComprobacion?.cancel();
    _estaVerificado = true;
    notifyListeners();
  }

  /// Reenvia el correo de verificacion y bloquea el boton un tiempo.
  Future<void> reenviarCorreo() async {
    if (!puedeReenviar) return;
    try {
      await _authRepository.enviarVerificacion();
      _aviso = 'Correo reenviado. Revisá tu bandeja.';
      _iniciarEsperaReenvio();
    } catch (_) {
      _aviso = 'No se pudo reenviar el correo. Probá de nuevo.';
    }
    notifyListeners();
  }

  /// Marca el aviso como mostrado.
  void limpiarAviso() => _aviso = null;

  /// Cierra la sesion actual.
  Future<void> cerrarSesion() async {
    detenerComprobacion();
    await _authRepository.cerrarSesion();
  }

  void _iniciarEsperaReenvio() {
    _segundosRestantes = esperaReenvio;
    _temporizadorReenvio?.cancel();
    _temporizadorReenvio = Timer.periodic(_unSegundo, (temporizador) {
      _segundosRestantes--;
      if (_segundosRestantes <= 0) {
        _segundosRestantes = 0;
        temporizador.cancel();
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    detenerComprobacion();
    super.dispose();
  }
}
