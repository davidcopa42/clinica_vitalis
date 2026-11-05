import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthException implements Exception {
  AuthException(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}

class AuthRepository {
  final AuthService _authService = AuthService();

  Stream<String?> get cambiosDeSesion =>
      _authService.cambiosDeUsuario.map((user) => user?.uid);

  String? get uidActual => _authService.usuarioActual?.uid;

  bool get correoVerificado =>
      _authService.usuarioActual?.emailVerified ?? false;

  Future<void> registrarConCorreo(String correo, String contrasena) async {
    try {
      await _authService.registrarConCorreo(correo, contrasena);
    } on FirebaseAuthException catch (e) {
      throw _traducirError(e);
    }
  }

  Future<void> iniciarConCorreo(String correo, String contrasena) async {
    try {
      await _authService.iniciarConCorreo(correo, contrasena);
    } on FirebaseAuthException catch (e) {
      throw _traducirError(e);
    }
  }

  Future<void> iniciarConGoogle() async {
    try {
      await _authService.iniciarConGoogle();
    } on FirebaseAuthException catch (e) {
      throw _traducirError(e);
    }
  }

  Future<void> enviarVerificacion() async {
    try {
      await _authService.enviarVerificacion();
    } on FirebaseAuthException catch (e) {
      throw _traducirError(e);
    }
  }

  Future<void> recargarUsuario() async {
    try {
      await _authService.recargarUsuario();
    } on FirebaseAuthException catch (e) {
      throw _traducirError(e);
    }
  }

  Future<void> recuperarContrasena(String correo) async {
    try {
      await _authService.recuperarContrasena(correo);
    } on FirebaseAuthException catch (e) {
      throw _traducirError(e);
    }
  }

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
