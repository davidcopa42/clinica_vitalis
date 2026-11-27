import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get cambiosDeUsuario => _auth.authStateChanges();
  User? get usuarioActual => _auth.currentUser;

  Future<void> registrarConCorreo(String correo, String contrasena) async {
    await _auth.createUserWithEmailAndPassword(
        email: correo, password: contrasena);
  }

  Future<void> iniciarConCorreo(String correo, String contrasena) async {
    await _auth.signInWithEmailAndPassword(email: correo, password: contrasena);
  }

  Future<UserCredential?> iniciarConGoogle() async {
    final GoogleSignInAccount? cuentaGoogle = await _googleSignIn.signIn();
    if (cuentaGoogle == null) return null; // El usuario cerró la ventana

    final GoogleSignInAuthentication autenticacionGoogle =
        await cuentaGoogle.authentication;
    final AuthCredential credencial = GoogleAuthProvider.credential(
      accessToken: autenticacionGoogle.accessToken,
      idToken: autenticacionGoogle.idToken,
    );

    return await _auth.signInWithCredential(credencial);
  }

  Future<void> enviarVerificacion() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> recargarUsuario() async {
    await _auth.currentUser?.reload();
  }

  Future<void> actualizarNombreVisible(String nombre) async {
    await _auth.currentUser?.updateDisplayName(nombre);
  }

  Future<void> recuperarContrasena(String correo) async {
    await _auth.sendPasswordResetEmail(email: correo);
  }

  Future<void> cerrarSesion() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
