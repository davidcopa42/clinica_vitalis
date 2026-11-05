import 'package:flutter/material.dart';
import '../data/repositories/perfil_repository.dart';

class PerfilProvider extends ChangeNotifier {
  final PerfilRepository _repository;
  Map<String, dynamic>? _perfilData;
  bool _isLoading = false;

  PerfilProvider({required PerfilRepository repository})
      : _repository = repository;

  Map<String, dynamic>? get perfilData => _perfilData;
  bool get isLoading => _isLoading;

  Future<void> cargarPerfil(String uid) async {
    if (_perfilData == null) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _perfilData = await _repository.cargarPerfilUsuario(uid);
    } catch (e) {
      debugPrint('Error al cargar perfil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> actualizarPerfil(
      String uid, Map<String, dynamic> nuevosDatos) async {
    await _repository.guardarPerfil(uid, nuevosDatos);
    await cargarPerfil(uid);
  }
}
