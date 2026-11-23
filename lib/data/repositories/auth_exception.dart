/// Error de autenticacion con un mensaje listo para mostrar al usuario.
class AuthException implements Exception {
  const AuthException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}
