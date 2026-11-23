import 'package:flutter/material.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/perfil_repository.dart';
import '../../core/estado_carga.dart';

class CrearCuentaViewModel extends ChangeNotifier {
  CrearCuentaViewModel({
    required AuthRepository authRepository,
    required PerfilRepository perfilRepository,
  })  : _authRepo = authRepository,
        _perfilRepo = perfilRepository;

  EstadoCarga _estadoCarga = EstadoCarga.inicial;
  String? _mensajeError;

  EstadoCarga get estadoCarga => _estadoCarga;
  String? get mensajeError => _mensajeError;

  final AuthRepository _authRepo;
  final PerfilRepository _perfilRepo;

  Future<void> registrarUsuario({
    required String nombre,
    required String apellido,
    required String correo,
    required String password,
  }) async {
    _estadoCarga = EstadoCarga.cargando;
    _mensajeError = null;
    notifyListeners();

    try {
      await _authRepo.registrarConCorreo(correo, password);

      await _authRepo
          .actualizarNombreVisible('${nombre.trim()} ${apellido.trim()}');

      final uid = _authRepo.uidActual;

      if (uid != null) {
        await _perfilRepo.guardarPerfil(uid, {
          'nombre': nombre.trim(),
          'apellido': apellido.trim(),
          'correo': correo.trim(),
          'telefono': '',
          'dni': '',
          'fechaNacimiento': '',
          'obraSocial': 'Particular',
          'numeroAfiliado': '',
          'photoUrl': '',
        });

        await _authRepo.enviarVerificacion();
      }

      _estadoCarga = EstadoCarga.exito;
    } on AuthException catch (e) {
      _estadoCarga = EstadoCarga.error;
      _mensajeError = e.mensaje;
    } catch (e) {
      _estadoCarga = EstadoCarga.error;
      _mensajeError = 'Ocurrió un error inesperado al registrarse.';
    } finally {
      notifyListeners();
    }
  }
}
