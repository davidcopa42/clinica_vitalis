import 'package:clinica_vitalis/data/repositories/auth_repository.dart';

/// [AuthRepository] en memoria para los tests.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.uidActual, this.correoVerificado = true});

  @override
  String? uidActual;

  @override
  bool correoVerificado;

  int vecesRecargado = 0;

  @override
  Stream<String?> get cambiosDeSesion => Stream.value(uidActual);

  @override
  String? get correoActual => 'paciente@test.com';

  @override
  String? get nombreVisible => 'Ana Paz';

  @override
  String? get fotoUrl => null;

  @override
  Future<void> registrarConCorreo(String correo, String contrasena) async {}

  @override
  Future<void> iniciarConCorreo(String correo, String contrasena) async {}

  @override
  Future<bool> iniciarConGoogle() async => true;

  @override
  Future<void> actualizarNombreVisible(String nombre) async {}

  @override
  Future<void> enviarVerificacion() async {}

  @override
  Future<void> recargarUsuario() async => vecesRecargado++;

  @override
  Future<void> recuperarContrasena(String correo) async {}

  @override
  Future<void> cerrarSesion() async => uidActual = null;
}
