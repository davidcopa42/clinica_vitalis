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

  Future<void> iniciarSesion(String correo, String password) async {
    _estadoCarga = EstadoCarga.cargando;
    _mensajeError = null;
    notifyListeners();

    try {
      await _authRepo.iniciarConCorreo(correo, password);

      _estadoCarga = EstadoCarga.exito;
    } on AuthException catch (e) {
      _estadoCarga = EstadoCarga.error;
      switch (e.codigo) {
        case 'user-not-found':
          _mensajeError = 'No existe una cuenta con este correo.';
          break;
        case 'wrong-password':
          _mensajeError = 'Contraseña incorrecta.';
          break;
        case 'invalid-email':
          _mensajeError = 'El formato del correo es inválido.';
          break;
        case 'user-disabled':
          _mensajeError = 'Este usuario ha sido deshabilitado.';
          break;
        case 'invalid-credential':
          _mensajeError = 'Credenciales inválidas. Verifique sus datos.';
          break;
        default:
          _mensajeError = 'Error de autenticación: ${e.detalle}';
      }
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
      // Conserva el texto que mostraba el error original de Firebase.
      _estadoCarga = EstadoCarga.error;
      _mensajeError =
          'No se pudo iniciar sesión con Google: ${e.textoOriginal}';
    } catch (e) {
      _estadoCarga = EstadoCarga.error;
      _mensajeError = 'No se pudo iniciar sesión con Google: $e';
    } finally {
      notifyListeners();
    }
  }
}
