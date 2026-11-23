import 'package:flutter/material.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/perfil_repository.dart';
import '../../core/estado_carga.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({
    required AuthRepository authRepository,
    required PerfilRepository perfilRepository,
  })  : _authRepo = authRepository,
        _perfilRepo = perfilRepository;

  EstadoCarga _estadoCarga = EstadoCarga.inicial;
  String? _mensajeError;
  bool _esNuevoUsuario = false;

  EstadoCarga get estadoCarga => _estadoCarga;
  String? get mensajeError => _mensajeError;
  bool get esNuevoUsuario => _esNuevoUsuario;

  final AuthRepository _authRepo;
  final PerfilRepository _perfilRepo;

  Future<void> iniciarSesion(String correo, String contrasena) async {
    _estadoCarga = EstadoCarga.cargando;
    _mensajeError = null;
    notifyListeners();

    try {
      await _authRepo.iniciarConCorreo(correo, contrasena);

      _estadoCarga = EstadoCarga.exito;
    } on AuthException catch (e) {
      _estadoCarga = EstadoCarga.error;
      _mensajeError = e.mensaje;
    } catch (e) {
      _estadoCarga = EstadoCarga.error;
      _mensajeError = 'Ocurrió un error inesperado: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> iniciarSesionConGoogle() async {
    _estadoCarga = EstadoCarga.cargando;
    _mensajeError = null;
    notifyListeners();

    try {
      final usuario = await _authRepo.iniciarConGoogle();
      if (usuario == null) {
        _estadoCarga = EstadoCarga.inicial;
        notifyListeners();
        return;
      }

      final perfilExistente =
          await _perfilRepo.cargarPerfilUsuario(usuario.uid);

      if (perfilExistente == null || perfilExistente.isEmpty) {
        _esNuevoUsuario = true;
        await _perfilRepo.guardarPerfil(usuario.uid, {
          'nombre': usuario.nombreVisible ?? 'Sin nombre',
          'correo': usuario.correo ?? '',
          'dni': '',
          'fechaNacimiento': '',
          'telefono': usuario.telefono ?? '',
          'obraSocial': '',
        });
      } else {
        _esNuevoUsuario = false;
      }

      _estadoCarga = EstadoCarga.exito;
    } on AuthException catch (e) {
      _estadoCarga = EstadoCarga.error;
      _mensajeError = 'No se pudo iniciar sesión con Google: ${e.mensaje}';
    } catch (e) {
      _estadoCarga = EstadoCarga.error;
      _mensajeError = 'No se pudo iniciar sesión con Google: $e';
    } finally {
      notifyListeners();
    }
  }
}
