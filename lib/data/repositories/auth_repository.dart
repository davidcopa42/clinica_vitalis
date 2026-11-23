/// Contrato para la autenticacion del paciente.
///
/// Los metodos que fallan lanzan [AuthException] con un mensaje traducido.
abstract class AuthRepository {
  /// Emite el uid del usuario cada vez que cambia la sesion (null si no hay).
  Stream<String?> get cambiosDeSesion;

  /// Uid del usuario con sesion iniciada, o null.
  String? get uidActual;

  /// Indica si el usuario actual ya verifico su correo.
  bool get correoVerificado;

  /// Correo del usuario actual, o null.
  String? get correoActual;

  /// Nombre visible del usuario actual, o null.
  String? get nombreVisible;

  /// Foto del usuario actual (por ejemplo, la de Google), o null.
  String? get fotoUrl;

  /// Crea una cuenta con correo y contrasena.
  Future<void> registrarConCorreo(String correo, String contrasena);

  /// Inicia sesion con correo y contrasena.
  Future<void> iniciarConCorreo(String correo, String contrasena);

  /// Inicia sesion con Google. Devuelve false si el usuario cancelo.
  Future<bool> iniciarConGoogle();

  /// Cambia el nombre visible del usuario actual.
  Future<void> actualizarNombreVisible(String nombre);

  /// Envia el correo de verificacion.
  Future<void> enviarVerificacion();

  /// Vuelve a leer el usuario actual (por ejemplo, tras verificar el correo).
  Future<void> recargarUsuario();

  /// Envia el enlace para restablecer la contrasena.
  Future<void> recuperarContrasena(String correo);

  /// Cierra la sesion actual.
  Future<void> cerrarSesion();
}
