import 'dart:async';

import 'package:clinica_vitalis/data/repositories/auth_repository.dart';
import 'package:clinica_vitalis/domain/models/usuario_autenticado.dart';

/// Repositorio de autenticacion falso y configurable.
///
/// Registra cada llamada en [llamadas] y lanza [errores] por nombre de
/// metodo cuando se configuran.
class FakeAuthRepository implements AuthRepository {
  String? uid;
  UsuarioAutenticado? usuario;
  bool verificado = false;
  final List<String> llamadas = [];
  final Map<String, Object> errores = {};

  /// Valor de [correoVerificado] despues de cada [recargarUsuario].
  bool? verificadoAlRecargar;

  Future<void> _registrar(String llamada, [String? detalle]) async {
    llamadas.add(detalle == null ? llamada : '$llamada:$detalle');
    final error = errores[llamada];
    if (error != null) throw error;
  }

  /// Permite simular cambios de sesion desde el test.
  final StreamController<String?> controladorSesion =
      StreamController<String?>.broadcast();

  @override
  Stream<String?> get cambiosDeSesion => controladorSesion.stream;

  @override
  String? get uidActual => uid;

  @override
  UsuarioAutenticado? get usuarioActual => usuario;

  @override
  bool get correoVerificado => verificado;

  @override
  Future<void> registrarConCorreo(String correo, String contrasena) =>
      _registrar('registrarConCorreo', correo);

  @override
  Future<void> iniciarConCorreo(String correo, String contrasena) =>
      _registrar('iniciarConCorreo', correo);

  @override
  Future<UsuarioAutenticado?> iniciarConGoogle() async {
    await _registrar('iniciarConGoogle');
    return null;
  }

  @override
  Future<void> enviarVerificacion() => _registrar('enviarVerificacion');

  @override
  Future<void> recargarUsuario() async {
    await _registrar('recargarUsuario');
    if (verificadoAlRecargar != null) verificado = verificadoAlRecargar!;
  }

  @override
  Future<void> actualizarNombreVisible(String nombre) =>
      _registrar('actualizarNombreVisible', nombre);

  @override
  Future<void> recuperarContrasena(String correo) =>
      _registrar('recuperarContrasena', correo);

  @override
  Future<void> cerrarSesion() => _registrar('cerrarSesion');
}
