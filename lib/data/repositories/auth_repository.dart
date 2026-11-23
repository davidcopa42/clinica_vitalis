import '../../domain/models/usuario_autenticado.dart';

/// Error de autenticación con un mensaje listo para mostrar al usuario.
class AuthException implements Exception {
  AuthException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Contrato para autenticar al paciente.
///
/// Las implementaciones traducen los errores del proveedor a
/// [AuthException].
abstract class AuthRepository {
  /// Emite el uid del usuario cada vez que cambia la sesión (null si no hay).
  Stream<String?> get cambiosDeSesion;

  /// Uid del usuario actual, o null si no hay sesión.
  String? get uidActual;

  /// Datos de la cuenta del usuario actual, o null si no hay sesión.
  UsuarioAutenticado? get usuarioActual;

  /// Si el usuario actual verificó su correo.
  bool get correoVerificado;

  Future<void> registrarConCorreo(String correo, String contrasena);

  Future<void> iniciarConCorreo(String correo, String contrasena);

  /// Inicia sesión con Google. Devuelve null si el usuario canceló.
  Future<UsuarioAutenticado?> iniciarConGoogle();

  Future<void> enviarVerificacion();

  Future<void> recargarUsuario();

  /// Cambia el nombre que muestra la cuenta del usuario actual.
  Future<void> actualizarNombreVisible(String nombre);

  Future<void> recuperarContrasena(String correo);

  Future<void> cerrarSesion();
}
