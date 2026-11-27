import '../services/conectividad_service.dart';
import 'conectividad_repository.dart';

/// Implementación de [ConectividadRepository] que consulta la red del
/// dispositivo mediante [ConectividadService].
class ConectividadRepositorioLocal implements ConectividadRepository {
  ConectividadRepositorioLocal({
    required ConectividadService conectividadService,
  }) : _servicio = conectividadService;

  final ConectividadService _servicio;

  @override
  Stream<bool> get cambiosDeConexion => _servicio.cambios;

  @override
  Future<bool> verificarConexion() => _servicio.hayRed();
}
