import 'package:clinica_vitalis/data/repositories/auth_repository.dart';
import 'package:clinica_vitalis/data/repositories/perfil_repository.dart';
import 'package:flutter/material.dart';

class PerfilViewModel extends ChangeNotifier {
  final PerfilRepository _perfilRepo;
  final AuthRepository _authRepo;

  Map<String, dynamic>? _perfilData;
  bool _isLoading = false;

  PerfilViewModel({
    required PerfilRepository repository,
    required AuthRepository authRepository,
  })  : _perfilRepo = repository,
        _authRepo = authRepository;

  Map<String, dynamic>? get perfilData => _perfilData;
  bool get isLoading => _isLoading;

  Future<void> cargarPerfil(String uid) async {
    if (_perfilData == null) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _perfilData = await _perfilRepo.cargarPerfilUsuario(uid);
    } catch (e) {
      debugPrint('Error al cargar perfil: $e');
    } finally {
      _isLoading = false;
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
