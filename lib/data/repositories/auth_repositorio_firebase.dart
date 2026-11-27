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
      _authService.cambiosDeUsuario.map((usuario) => usuario?.uid);

  @override
  String? get uidActual => _authService.usuarioActual?.uid;

  @override
  UsuarioAutenticado? get usuarioActual {
    final usuario = _authService.usuarioActual;
    return usuario == null ? null : _aUsuarioAutenticado(usuario);
  }

  @override
  bool get correoVerificado =>
      _authService.usuarioActual?.emailVerified ?? false;

  @override
  Future<void> registrarConCorreo(String correo, String contrasena) async {
    try {
      await _authService.registrarConCorreo(correo, contrasena);
    } on FirebaseAuthException catch (error) {
      throw _traducirError(error);
    }
  }

  @override
  Future<void> iniciarConCorreo(String correo, String contrasena) async {
    try {
      await _authService.iniciarConCorreo(correo, contrasena);
    } on FirebaseAuthException catch (error) {
      throw _traducirError(error);
    }
  }

  @override
  Future<UsuarioAutenticado?> iniciarConGoogle() async {
    try {
      final credencial = await _authService.iniciarConGoogle();
      final usuario = credencial?.user;
      if (usuario == null) return null;
      return _aUsuarioAutenticado(usuario);
    } on FirebaseAuthException catch (error) {
      throw _traducirError(error);
    }
  }

  @override
  Future<void> enviarVerificacion() async {
    try {
      await _authService.enviarVerificacion();
    } on FirebaseAuthException catch (error) {
      throw _traducirError(error);
    }
  }

  @override
  Future<void> recargarUsuario() async {
    try {
      await _authService.recargarUsuario();
    } on FirebaseAuthException catch (error) {
      throw _traducirError(error);
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
    } on FirebaseAuthException catch (error) {
      throw _traducirError(error);
    }
  }

  @override
  Future<void> cerrarSesion() async {
    await _authService.cerrarSesion();
  }

  UsuarioAutenticado _aUsuarioAutenticado(User usuario) {
    return UsuarioAutenticado(
      uid: usuario.uid,
      nombreVisible: usuario.displayName,
      correo: usuario.email,
      telefono: usuario.phoneNumber,
      fotoUrl: usuario.photoURL,
    );
  }

  AuthException _traducirError(FirebaseAuthException error) {
    return AuthException(_mensajePara(error.code));
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
