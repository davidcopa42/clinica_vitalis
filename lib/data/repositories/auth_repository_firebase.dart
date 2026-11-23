import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import 'auth_exception.dart';
import 'auth_repository.dart';

/// Implementacion de [AuthRepository] sobre [AuthService] (Firebase).
class AuthRepositoryFirebase implements AuthRepository {
  AuthRepositoryFirebase({required AuthService authService})
      : _authService = authService;

  final AuthService _authService;

  @override
  Stream<String?> get cambiosDeSesion =>
      _authService.cambiosDeUsuario.map((usuario) => usuario?.uid);

  @override
  String? get uidActual => _authService.usuarioActual?.uid;

  @override
  bool get correoVerificado =>
      _authService.usuarioActual?.emailVerified ?? false;

  @override
  String? get correoActual => _authService.usuarioActual?.email;

  @override
  String? get nombreVisible => _authService.usuarioActual?.displayName;

  @override
  String? get fotoUrl => _authService.usuarioActual?.photoURL;

  @override
  Future<void> registrarConCorreo(String correo, String contrasena) =>
      _traducirErrores(
        () => _authService.registrarConCorreo(correo, contrasena),
      );

  @override
  Future<void> iniciarConCorreo(String correo, String contrasena) =>
      _traducirErrores(
        () => _authService.iniciarConCorreo(correo, contrasena),
      );

  @override
  Future<bool> iniciarConGoogle() => _traducirErrores(() async {
        final credencial = await _authService.iniciarConGoogle();
        return credencial != null;
      });

  @override
  Future<void> actualizarNombreVisible(String nombre) => _traducirErrores(
        () => _authService.actualizarNombreVisible(nombre),
      );

  @override
  Future<void> enviarVerificacion() =>
      _traducirErrores(_authService.enviarVerificacion);

  @override
  Future<void> recargarUsuario() =>
      _traducirErrores(_authService.recargarUsuario);

  @override
  Future<void> recuperarContrasena(String correo) =>
      _traducirErrores(() => _authService.recuperarContrasena(correo));

  @override
  Future<void> cerrarSesion() => _traducirErrores(_authService.cerrarSesion);

  /// Ejecuta [accion] y convierte los errores de Firebase en [AuthException].
  Future<T> _traducirErrores<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mensajePara(error.code));
    }
  }

  String _mensajePara(String codigo) {
    switch (codigo) {
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Correo o contraseña incorrectos.';
      case 'user-disabled':
        return 'Este usuario fue deshabilitado.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'network-request-failed':
        return 'Sin conexión. Revisá internet.';
      case 'too-many-requests':
        return 'Demasiados intentos. Probá en unos minutos.';
      default:
        return 'Ocurrió un error al autenticar.';
    }
  }
}
