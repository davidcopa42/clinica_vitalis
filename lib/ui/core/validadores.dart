/// Validadores de formularios compartidos. Devuelven el mensaje de error
/// o null si el valor es valido.
abstract final class Validadores {
  static const largoMinimoContrasena = 8;

  static final _letra = RegExp(r'[a-zA-Z]');
  static final _numero = RegExp(r'[0-9]');
  static final _dni = RegExp(r'^\d{7,8}$');
  static final _telefono = RegExp(r'^\d{8,15}$');

  /// Exige que el campo tenga algun texto.
  static String? Function(String?) requerido([String mensaje = 'Requerido']) {
    return (valor) => _estaVacio(valor) ? mensaje : null;
  }

  /// Correo obligatorio con formato basico.
  static String? correo(String? valor) {
    if (_estaVacio(valor)) return 'Ingresá tu correo';
    if (!valor!.contains('@')) return 'Correo inválido';
    return null;
  }

  /// Contrasena obligatoria para iniciar sesion.
  static String? contrasenaIngreso(String? valor) =>
      _estaVacio(valor) ? 'Ingresá tu contraseña' : null;

  /// Contrasena nueva: largo minimo, al menos una letra y un numero.
  static String? contrasenaNueva(String? valor) {
    if (_estaVacio(valor)) return 'Ingresá tu contraseña';
    if (valor!.length < largoMinimoContrasena) {
      return 'Debe tener al menos $largoMinimoContrasena caracteres';
    }
    if (!valor.contains(_letra)) return 'Debe contener al menos una letra';
    if (!valor.contains(_numero)) return 'Debe contener al menos un número';
    return null;
  }

  /// Exige que el valor coincida con [original] (repetir contrasena).
  static String? Function(String?) confirmacion(String Function() original) {
    return (valor) {
      if (_estaVacio(valor)) return 'Confirmá tu contraseña';
      if (valor != original()) return 'Las contraseñas no coinciden';
      return null;
    };
  }

  /// DNI de 7 u 8 digitos.
  static String? dni(String? valor) {
    if (_estaVacio(valor)) return 'Ingresá tu DNI';
    if (!_dni.hasMatch(valor!)) return 'Debe tener 7 u 8 dígitos';
    return null;
  }

  /// Telefono de 8 a 15 digitos.
  static String? telefono(String? valor) {
    if (_estaVacio(valor)) return 'Ingresá tu teléfono';
    if (!_telefono.hasMatch(valor!)) return 'Debe tener entre 8 y 15 dígitos';
    return null;
  }

  static bool _estaVacio(String? valor) => valor == null || valor.isEmpty;
}
