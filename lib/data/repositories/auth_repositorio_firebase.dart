import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import 'auth_repository.dart';

/// Implementación de [AuthRepository] con Firebase Auth mediante
/// [AuthService].
class AuthRepositorioFirebase implements AuthRepository {
  AuthRepositorioFirebase({required AuthService authService})
      : _authService = authService;

  final AuthService _authService;

  @override
  Stream<String?> get cambiosDeSesion =>
      _authService.cambiosDeUsuario.map((user) => user?.uid);

  @override
  String? get uidActual => _authService.usuarioActual?.uid;

  @override
  bool get correoVerificado =>
      _authService.usuarioActual?.emailVerified ?? false;

  @override
  Future<void> registrarConCorreo(String correo, String contrasena) async {
    try {
      await _authService.registrarConCorreo(correo, contrasena);
    } on FirebaseAuthException catch (e) {
      throw _traducirError(e);
    }
  }

  @override
  Future<void> iniciarConCorreo(String correo, String contrasena) async {
    try {
      await _authService.iniciarConCorreo(correo, contrasena);
    } on FirebaseAuthException catch (e) {
      throw _traducirError(e);
    }
  }

  @override
  Future<void> iniciarConGoogle() async {
    try {
      await _authService.iniciarConGoogle();
    } on FirebaseAuthException catch (e) {
      throw _traducirError(e);
    }
  }

  @override
  Future<void> enviarVerificacion() async {
    try {
      await _authService.enviarVerificacion();
    } on FirebaseAuthException catch (e) {
      throw _traducirError(e);
    }
  }

  @override
  Future<void> recargarUsuario() async {
    try {
      await _authService.recargarUsuario();
    } on FirebaseAuthException catch (e) {
      throw _traducirError(e);
    }
  }

  /// No traduce errores: se conserva el comportamiento previo, en el que
  /// la llamada a Firebase se hacía directo desde el ViewModel.
  @override
  Future<void> actualizarNombreVisible(String nombre) async {
    await _authService.actualizarNombreVisible(nombre);
  }

  @override
  Future<void> recuperarContrasena(String correo) async {
    try {
      await _authService.recuperarContrasena(correo);
    } on FirebaseAuthException catch (e) {
      throw _traducirError(e);
    }
  }

  @override
  Future<void> cerrarSesion() async {
    await _authService.cerrarSesion();
  }

  AuthException _traducirError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return AuthException('El correo no es válido.');
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return AuthException('Correo o contraseña incorrectos.');
      case 'email-already-in-use':
        return AuthException('Ya existe una cuenta con ese correo.');
      case 'weak-password':
        return AuthException('La contraseña es muy débil.');
      case 'network-request-failed':
        return AuthException('Sin conexión. Revisá internet.');
      case 'too-many-requests':
        return AuthException('Demasiados intentos. Probá en unos minutos.');
      default:
        return AuthException('Ocurrió un error al autenticar.');
    }
  }
}
