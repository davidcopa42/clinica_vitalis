import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Acceso directo a Firebase Auth y Google Sign-In.
class AuthService {
  AuthService({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  /// Emite el usuario cada vez que cambia la sesion.
  Stream<User?> get cambiosDeUsuario => _auth.authStateChanges();

  /// Usuario con sesion iniciada, o null.
  User? get usuarioActual => _auth.currentUser;

  /// Crea una cuenta con correo y contrasena.
  Future<void> registrarConCorreo(String correo, String contrasena) async {
    await _auth.createUserWithEmailAndPassword(
      email: correo,
      password: contrasena,
    );
  }

  /// Inicia sesion con correo y contrasena.
  Future<void> iniciarConCorreo(String correo, String contrasena) async {
    await _auth.signInWithEmailAndPassword(email: correo, password: contrasena);
  }

  /// Inicia sesion con Google. Devuelve null si el usuario cerro la ventana.
  Future<UserCredential?> iniciarConGoogle() async {
    final cuentaGoogle = await _googleSignIn.signIn();
    if (cuentaGoogle == null) return null;

    final autenticacion = await cuentaGoogle.authentication;
    final credencial = GoogleAuthProvider.credential(
      accessToken: autenticacion.accessToken,
      idToken: autenticacion.idToken,
    );

    return _auth.signInWithCredential(credencial);
  }

  /// Cambia el nombre visible del usuario actual.
  Future<void> actualizarNombreVisible(String nombre) async {
    await _auth.currentUser?.updateDisplayName(nombre);
  }

  /// Envia el correo de verificacion al usuario actual.
  Future<void> enviarVerificacion() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Vuelve a leer los datos del usuario actual desde Firebase.
  Future<void> recargarUsuario() async {
    await _auth.currentUser?.reload();
  }

  /// Envia el enlace para restablecer la contrasena.
  Future<void> recuperarContrasena(String correo) async {
    await _auth.sendPasswordResetEmail(email: correo);
  }

  /// Cierra la sesion en Google y en Firebase.
  Future<void> cerrarSesion() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
