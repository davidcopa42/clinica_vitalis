import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/usuario_autenticado.dart';
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
  Future<UsuarioAutenticado?> iniciarConGoogle() async {
    try {
      final credencial = await _authService.iniciarConGoogle();
      final usuario = credencial?.user;
      if (usuario == null) return null;
      return UsuarioAutenticado(
        uid: usuario.uid,
        nombreVisible: usuario.displayName,
        correo: usuario.email,
        telefono: usuario.phoneNumber,
      );
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
    return AuthException(
      _mensajePara(e.code),
      codigo: e.code,
      detalle: e.message,
      textoOriginal: e.toString(),
    );
  }

  String _mensajePara(String codigo) {
    switch (codigo) {
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Correo o contraseña incorrectos.';
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
