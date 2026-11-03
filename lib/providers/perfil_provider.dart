import 'package:flutter/material.dart';
import '../data/repositories/perfil_repository.dart';

class PerfilProvider extends ChangeNotifier {
  final PerfilRepository _repository;
  Map<String, dynamic>? _perfilData;
  bool _isLoading = false;

  PerfilProvider({required PerfilRepository repository}) : _repository = repository;

  Map<String, dynamic>? get perfilData => _perfilData;
  bool get isLoading => _isLoading;

  Future<void> cargarPerfil(String uid) async {
    _isLoading = true;
    notifyListeners();
    _perfilData = await _repository.cargarPerfilUsuario(uid);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> actualizarPerfil(String uid, Map<String, dynamic> nuevosDatos) async {
    await _repository.actualizarDatosPerfil(
      uid,
      nombre: nuevosDatos['nombre'],
      telefono: nuevosDatos['telefono'],
      obraSocial: nuevosDatos['obraSocial'],
    );
    await cargarPerfil(uid);
  }
}