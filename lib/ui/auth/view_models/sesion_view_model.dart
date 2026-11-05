import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/perfil_repository.dart';
import '../../../domain/models/paciente.dart';

enum EstadoSesion { sinSesion, correoSinVerificar, perfilIncompleto, lista }

class SesionViewModel extends ChangeNotifier {
  final AuthRepository _authRepo;
  final PerfilRepository _perfilRepo;

  StreamSubscription<String?>? _suscripcionSesion;

  EstadoSesion _estadoSesion = EstadoSesion.sinSesion;
  String? _uidActual;
  Paciente? _pacienteActual;

  bool _isCargando = true;

  EstadoSesion get estadoSesion => _estadoSesion;
  String? get uidActual => _uidActual;
  Paciente? get pacienteActual => _pacienteActual;
  bool get isCargando => _isCargando;

  SesionViewModel({
    required AuthRepository authRepo,
    required PerfilRepository perfilRepo,
  })  : _authRepo = authRepo,
        _perfilRepo = perfilRepo {
    _calcularEstadoSesion(_authRepo.uidActual);
    _suscripcionSesion =
        _authRepo.cambiosDeSesion.listen(_calcularEstadoSesion);
  }

  Future<void> _calcularEstadoSesion(String? uid) async {
    _uidActual = uid;

    if (uid == null) {
      _estadoSesion = EstadoSesion.sinSesion;
      _pacienteActual = null;
      _isCargando = false;
      notifyListeners();
      return;
    }

    _isCargando = true;
    notifyListeners();

    try {
      if (!_authRepo.correoVerificado) {
        _estadoSesion = EstadoSesion.correoSinVerificar;
        _pacienteActual = null;
      } else {
        final Paciente? paciente = await _perfilRepo.obtenerPerfil(uid);
        _pacienteActual = paciente;

        if (paciente == null || !paciente.perfilCompleto) {
          _estadoSesion = EstadoSesion.perfilIncompleto;
        } else {
          _estadoSesion = EstadoSesion.lista;
        }
      }
    } catch (e) {
      debugPrint('Error silencioso atrapado en SesionViewModel: $e');
      _pacienteActual = null;
      _estadoSesion = EstadoSesion.perfilIncompleto;
    } finally {
      _isCargando = false;
      notifyListeners();
    }
  }

  Future<void> recargarYCalcular() async {
    _isCargando = true;
    notifyListeners();
    await _authRepo.recargarUsuario();
    await _calcularEstadoSesion(_uidActual);
  }

  @override
  void dispose() {
    _suscripcionSesion?.cancel();
    super.dispose();
  }
}
