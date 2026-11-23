import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/perfil_repository.dart';
import '../../../domain/models/paciente.dart';
import '../../core/estado_carga.dart';

/// Estado y comandos de la pantalla de inicio de sesion.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({
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

  /// Vuelve al estado inicial (por ejemplo, al volver a mostrar la pantalla).
  void reiniciar() {
    _estado = EstadoCarga.inicial;
    _mensajeError = null;
    notifyListeners();
  }

  /// Inicia sesion con correo y contrasena.
  Future<void> iniciarSesion(String correo, String contrasena) async {
    _empezarCarga();
    try {
      await _authRepository.iniciarConCorreo(correo, contrasena);
      _estado = EstadoCarga.exito;
    } on AuthException catch (error) {
      _fallar(error.mensaje);
    } catch (_) {
      _fallar('Ocurrió un error inesperado al iniciar sesión.');
    } finally {
      notifyListeners();
    }
  }

  /// Inicia sesion con Google y crea un perfil base si es la primera vez.
  Future<void> iniciarSesionConGoogle() async {
    _empezarCarga();
    try {
      final inicioSesion = await _authRepository.iniciarConGoogle();
      if (!inicioSesion) {
        _estado = EstadoCarga.inicial;
        return;
      }
      await _crearPerfilBaseSiFalta();
      _estado = EstadoCarga.exito;
    } on AuthException catch (error) {
      _fallar(error.mensaje);
    } catch (_) {
      _fallar('No se pudo iniciar sesión con Google.');
    } finally {
      notifyListeners();
    }
  }

  Future<void> _crearPerfilBaseSiFalta() async {
    final uid = _authRepository.uidActual;
    if (uid == null) return;

    final perfilExistente = await _perfilRepository.obtenerPerfil(uid);
    if (perfilExistente != null) return;

    final partesNombre = (_authRepository.nombreVisible ?? '').split(' ');
    await _perfilRepository.guardarPerfil(
      Paciente(
        uid: uid,
        nombre: partesNombre.first,
        apellido: partesNombre.skip(1).join(' '),
        correo: _authRepository.correoActual ?? '',
        fotoUrl: _authRepository.fotoUrl,
      ),
    );
  }

  void _empezarCarga() {
    _estado = EstadoCarga.cargando;
    _mensajeError = null;
    notifyListeners();
  }

  void _fallar(String mensaje) {
    _estado = EstadoCarga.error;
    _mensajeError = mensaje;
  }
}
