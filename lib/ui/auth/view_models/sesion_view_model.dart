import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/perfil_repository.dart';
import '../../../domain/models/paciente.dart';
import 'estado_sesion.dart';

/// Calcula en que [EstadoSesion] esta el paciente a partir de la sesion
/// de [AuthRepository] y del perfil de [PerfilRepository].
class SesionViewModel extends ChangeNotifier {
  SesionViewModel({
    required AuthRepository authRepository,
    required PerfilRepository perfilRepository,
  })  : _authRepository = authRepository,
        _perfilRepository = perfilRepository {
    _suscripcionSesion =
        _authRepository.cambiosDeSesion.listen(_calcularEstadoSesion);
  }

  final AuthRepository _authRepository;
  final PerfilRepository _perfilRepository;
  late final StreamSubscription<String?> _suscripcionSesion;

  EstadoSesion _estadoSesion = EstadoSesion.sinSesion;
  Paciente? _pacienteActual;
  bool _estaCargando = true;

  EstadoSesion get estadoSesion => _estadoSesion;
  Paciente? get pacienteActual => _pacienteActual;
  bool get estaCargando => _estaCargando;

  /// Relee el usuario y el perfil, por ejemplo tras verificar el correo
  /// o completar el perfil.
  Future<void> recargarSesion() async {
    _estaCargando = true;
    notifyListeners();
    await _authRepository.recargarUsuario();
    await _calcularEstadoSesion(
      _authRepository.uidActual,
      forzarRecarga: true,
    );
  }

  Future<void> _calcularEstadoSesion(
    String? uid, {
    bool forzarRecarga = false,
  }) async {
    if (uid == null) {
      _actualizar(EstadoSesion.sinSesion, paciente: null);
      return;
    }

    if (!_authRepository.correoVerificado) {
      _actualizar(EstadoSesion.correoSinVerificar, paciente: null);
      return;
    }

    _estaCargando = true;
    notifyListeners();

    try {
      final paciente = await _perfilRepository.obtenerPerfil(
        uid,
        forzarRecarga: forzarRecarga,
      );
      final estaCompleto = paciente?.perfilCompleto ?? false;
      _actualizar(
        estaCompleto ? EstadoSesion.lista : EstadoSesion.perfilIncompleto,
        paciente: paciente,
      );
    } catch (_) {
      _actualizar(EstadoSesion.perfilIncompleto, paciente: null);
    }
  }

  void _actualizar(EstadoSesion estado, {required Paciente? paciente}) {
    _estadoSesion = estado;
    _pacienteActual = paciente;
    _estaCargando = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _suscripcionSesion.cancel();
    super.dispose();
  }
}
