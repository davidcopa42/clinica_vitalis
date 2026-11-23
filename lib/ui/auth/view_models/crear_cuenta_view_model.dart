import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../data/repositories/auth_repositorio_firebase.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/perfil_repositorio_firestore.dart';
import '../../../data/repositories/perfil_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/perfil_service.dart';
import '../../core/estado_carga.dart';

class CrearCuentaViewModel extends ChangeNotifier {
  EstadoCarga _estadoCarga = EstadoCarga.inicial;
  String? _mensajeError;

  EstadoCarga get estadoCarga => _estadoCarga;
  String? get mensajeError => _mensajeError;

  final AuthRepository _authRepo =
      AuthRepositorioFirebase(authService: AuthService());
  final PerfilRepository _perfilRepo =
      PerfilRepositorioFirestore(perfilService: PerfilService());

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

      final userActual = FirebaseAuth.instance.currentUser;
      await userActual
          ?.updateDisplayName('${nombre.trim()} ${apellido.trim()}');

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
