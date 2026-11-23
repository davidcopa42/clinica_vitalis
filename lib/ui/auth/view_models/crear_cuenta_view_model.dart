import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/perfil_repository.dart';
import '../../../domain/models/paciente.dart';
import '../../core/estado_carga.dart';
import '../../core/obras_sociales.dart';

/// Estado y comandos de la pantalla para crear una cuenta.
class CrearCuentaViewModel extends ChangeNotifier {
  CrearCuentaViewModel({
    required AuthRepository authRepository,
    required PerfilRepository perfilRepository,
  })  : _authRepository = authRepository,
        _perfilRepository = perfilRepository;

  final AuthRepository _authRepository;
  final PerfilRepository _perfilRepository;

  EstadoCarga _estado = EstadoCarga.inicial;
  String? _mensajeError;

  EstadoCarga get estado => _estado;
  String? get mensajeError => _mensajeError;
  bool get estaCargando => _estado == EstadoCarga.cargando;
  bool get tieneError => _estado == EstadoCarga.error;
  bool get fueRegistrado => _estado == EstadoCarga.exito;

  /// Vuelve al estado inicial (por ejemplo, al abrir la pantalla).
  void reiniciar() {
    _estado = EstadoCarga.inicial;
    _mensajeError = null;
    notifyListeners();
  }

  /// Crea la cuenta, guarda el perfil base y envia la verificacion.
  Future<void> registrarUsuario({
    required String nombre,
    required String apellido,
    required String correo,
    required String contrasena,
  }) async {
    _estado = EstadoCarga.cargando;
    _mensajeError = null;
    notifyListeners();

    try {
      await _authRepository.registrarConCorreo(correo, contrasena);
      await _authRepository.actualizarNombreVisible('$nombre $apellido');

      final uid = _authRepository.uidActual;
      if (uid != null) {
        await _perfilRepository.guardarPerfil(
          Paciente(
            uid: uid,
            nombre: nombre,
            apellido: apellido,
            correo: correo,
            obraSocial: ObrasSociales.particular,
          ),
        );
        await _authRepository.enviarVerificacion();
      }

      _estado = EstadoCarga.exito;
    } on AuthException catch (error) {
      _estado = EstadoCarga.error;
      _mensajeError = error.mensaje;
    } catch (_) {
      _estado = EstadoCarga.error;
      _mensajeError = 'Ocurrió un error inesperado al registrarse.';
    } finally {
      notifyListeners();
    }
  }
}
