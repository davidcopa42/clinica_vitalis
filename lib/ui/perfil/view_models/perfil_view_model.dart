import 'package:clinica_vitalis/data/repositories/auth_repository.dart';
import 'package:clinica_vitalis/data/repositories/perfil_repository.dart';
import 'package:flutter/material.dart';

class PerfilViewModel extends ChangeNotifier {
  final PerfilRepository _perfilRepo;
  final AuthRepository _authRepo;

  Map<String, dynamic>? _datosPerfil;
  bool _estaCargando = false;

  PerfilViewModel({
    required PerfilRepository repository,
    required AuthRepository authRepository,
  })  : _perfilRepo = repository,
        _authRepo = authRepository;

  Map<String, dynamic>? get datosPerfil {
    final datos = _datosPerfil;
    return datos == null ? null : Map.unmodifiable(datos);
  }
  bool get estaCargando => _estaCargando;

  /// Foto de la cuenta, o null si no tiene.
  String? get fotoUrl => _authRepo.usuarioActual?.fotoUrl;

  /// Correo de la cuenta para mostrar.
  String get correoActual =>
      _authRepo.usuarioActual?.correo ?? 'Sin correo electrónico';

  Future<void> cargarPerfil(String uid) async {
    if (_datosPerfil == null) {
      _estaCargando = true;
      notifyListeners();
    }

    try {
      _datosPerfil = await _perfilRepo.cargarPerfilUsuario(uid);
    } catch (error) {
      debugPrint('Error al cargar perfil: $error');
    } finally {
      _estaCargando = false;
      notifyListeners();
    }
  }

  Future<void> actualizarPerfil(
      String uid, Map<String, dynamic> nuevosDatos) async {
    await _perfilRepo.guardarPerfil(uid, nuevosDatos);
    await cargarPerfil(uid);
  }

  Future<void> cerrarSesion() async {
    await _authRepo.cerrarSesion();
  }
}
