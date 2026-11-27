/// Datos básicos de la cuenta con la que el usuario inició sesión.
class UsuarioAutenticado {
  const UsuarioAutenticado({
    required this.uid,
    this.nombreVisible,
    this.correo,
    this.telefono,
    this.fotoUrl,
  });

  final String uid;
  final String? nombreVisible;
  final String? correo;
  final String? telefono;
  final String? fotoUrl;
}
