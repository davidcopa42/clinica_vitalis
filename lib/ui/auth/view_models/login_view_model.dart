import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../data/services/perfil_service.dart';
import '../../core/estado_carga.dart';

class LoginViewModel extends ChangeNotifier {
  EstadoCarga _estadoCarga = EstadoCarga.inicial;
  String? _mensajeError;
  bool _esNuevoUsuario = false;

  EstadoCarga get estadoCarga => _estadoCarga;
  String? get mensajeError => _mensajeError;
  bool get esNuevoUsuario => _esNuevoUsuario;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final PerfilService _perfilService = PerfilService();

  Future<void> iniciarSesion(String correo, String password) async {
    _estadoCarga = EstadoCarga.cargando;
    _mensajeError = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: correo,
        password: password,
      );

      _estadoCarga = EstadoCarga.exito;
    } on FirebaseAuthException catch (e) {
      _estadoCarga = EstadoCarga.error;
      switch (e.code) {
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
          _mensajeError = 'Error de autenticación: ${e.message}';
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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _estadoCarga = EstadoCarga.inicial;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final perfilExistente = await _perfilService.obtenerPerfil(user.uid);

        if (perfilExistente == null || perfilExistente.isEmpty) {
          _esNuevoUsuario = true;
          await _perfilService.guardarPerfil(user.uid, {
            'nombre': user.displayName ?? 'Sin nombre',
            'correo': user.email ?? '',
            'dni': '',
            'fechaNacimiento': '',
            'telefono': user.phoneNumber ?? '',
            'obraSocial': '',
          });
        } else {
          _esNuevoUsuario = false;
        }
      }

      _estadoCarga = EstadoCarga.exito;
    } catch (e) {
      _estadoCarga = EstadoCarga.error;
      _mensajeError = 'No se pudo iniciar sesión con Google: $e';
    } finally {
      notifyListeners();
    }
  }
}
