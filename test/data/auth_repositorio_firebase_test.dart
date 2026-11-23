import 'dart:async';

import 'package:clinica_vitalis/data/repositories/auth_repositorio_firebase.dart';
import 'package:clinica_vitalis/data/repositories/auth_repository.dart';
import 'package:clinica_vitalis/data/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usuario de Firebase falso con solo los datos que lee el repositorio.
class FakeUser extends Fake implements User {
  FakeUser({
    required this.uid,
    this.emailVerified = false,
    this.displayName,
    this.email,
    this.phoneNumber,
  });

  @override
  final String uid;

  @override
  final bool emailVerified;

  @override
  final String? displayName;

  @override
  final String? email;

  @override
  final String? phoneNumber;
}

/// Credencial falsa que solo expone el usuario.
class FakeUserCredential extends Fake implements UserCredential {
  FakeUserCredential(this.user);

  @override
  final User? user;
}

/// Servicio de autenticacion falso: registra llamadas y puede lanzar errores.
class FakeAuthService implements AuthService {
  final StreamController<User?> controladorUsuarios = StreamController<User?>();
  User? usuario;
  Object? error;
  final List<String> llamadas = [];

  Future<void> _registrar(String llamada) async {
    llamadas.add(llamada);
    if (error != null) throw error!;
  }

  @override
  Stream<User?> get cambiosDeUsuario => controladorUsuarios.stream;

  @override
  User? get usuarioActual => usuario;

  @override
  Future<void> registrarConCorreo(String correo, String contrasena) =>
      _registrar('registrar:$correo:$contrasena');

  @override
  Future<void> iniciarConCorreo(String correo, String contrasena) =>
      _registrar('iniciar:$correo:$contrasena');

  @override
  Future<UserCredential?> iniciarConGoogle() async {
    await _registrar('google');
    return credencialDeGoogle;
  }

  /// Lo que devuelve iniciarConGoogle; null simula que el usuario canceló.
  UserCredential? credencialDeGoogle;

  @override
  Future<void> enviarVerificacion() => _registrar('verificacion');

  @override
  Future<void> recargarUsuario() => _registrar('recargar');

  @override
  Future<void> actualizarNombreVisible(String nombre) =>
      _registrar('nombre:$nombre');

  @override
  Future<void> recuperarContrasena(String correo) =>
      _registrar('recuperar:$correo');

  @override
  Future<void> cerrarSesion() => _registrar('cerrar');
}

void main() {
  late FakeAuthService servicio;
  late AuthRepositorioFirebase repositorio;

  setUp(() {
    servicio = FakeAuthService();
    repositorio = AuthRepositorioFirebase(authService: servicio);
  });

  // Sin await: close() no termina si el stream nunca tuvo oyente.
  tearDown(() {
    servicio.controladorUsuarios.close();
  });

  group('estado de la sesion', () {
    test('sin usuario no hay uid y el correo no esta verificado', () {
      expect(repositorio.uidActual, isNull);
      expect(repositorio.correoVerificado, isFalse);
    });

    test('con usuario expone su uid y si verifico el correo', () {
      servicio.usuario = FakeUser(uid: 'abc', emailVerified: true);

      expect(repositorio.uidActual, 'abc');
      expect(repositorio.correoVerificado, isTrue);
    });

    test('cambiosDeSesion emite el uid o null', () async {
      final uids = <String?>[];
      final suscripcion = repositorio.cambiosDeSesion.listen(uids.add);

      servicio.controladorUsuarios
        ..add(FakeUser(uid: 'abc'))
        ..add(null);
      await pumpEventQueue();
      await suscripcion.cancel();

      expect(uids, ['abc', null]);
    });
  });

  group('delegacion al servicio', () {
    test('cada metodo llama al servicio con sus datos', () async {
      await repositorio.registrarConCorreo('a@b.com', 'clave1');
      await repositorio.iniciarConCorreo('a@b.com', 'clave2');
      await repositorio.iniciarConGoogle();
      await repositorio.enviarVerificacion();
      await repositorio.recargarUsuario();
      await repositorio.recuperarContrasena('a@b.com');
      await repositorio.cerrarSesion();

      expect(servicio.llamadas, [
        'registrar:a@b.com:clave1',
        'iniciar:a@b.com:clave2',
        'google',
        'verificacion',
        'recargar',
        'recuperar:a@b.com',
        'cerrar',
      ]);
    });

    test('actualizarNombreVisible pasa el nombre al servicio', () async {
      await repositorio.actualizarNombreVisible('Ana López');

      expect(servicio.llamadas, ['nombre:Ana López']);
    });

    test('actualizarNombreVisible no traduce los errores de Firebase',
        () async {
      servicio.error = FirebaseAuthException(code: 'network-request-failed');

      await expectLater(
        repositorio.actualizarNombreVisible('Ana López'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  group('iniciarConGoogle', () {
    test('si el usuario cancela devuelve null', () async {
      expect(await repositorio.iniciarConGoogle(), isNull);
    });

    test('devuelve los datos del usuario de Google', () async {
      servicio.credencialDeGoogle = FakeUserCredential(
        FakeUser(
          uid: 'uid-google',
          displayName: 'Ana López',
          email: 'ana@gmail.com',
          phoneNumber: '+54261',
        ),
      );

      final usuario = await repositorio.iniciarConGoogle();

      expect(usuario!.uid, 'uid-google');
      expect(usuario.nombreVisible, 'Ana López');
      expect(usuario.correo, 'ana@gmail.com');
      expect(usuario.telefono, '+54261');
    });
  });

  group('datos transitorios de AuthException', () {
    test('conserva codigo, detalle y texto del error original', () async {
      final original = FirebaseAuthException(
        code: 'user-disabled',
        message: 'The user account has been disabled.',
      );
      servicio.error = original;

      await expectLater(
        repositorio.iniciarConCorreo('a@b.com', 'clave'),
        throwsA(
          isA<AuthException>()
              .having((e) => e.codigo, 'codigo', 'user-disabled')
              .having(
                (e) => e.detalle,
                'detalle',
                'The user account has been disabled.',
              )
              .having(
                (e) => e.textoOriginal,
                'textoOriginal',
                original.toString(),
              ),
        ),
      );
    });
  });

  group('traduccion de errores de Firebase', () {
    const mensajesPorCodigo = {
      'invalid-email': 'El correo no es válido.',
      'invalid-credential': 'Correo o contraseña incorrectos.',
      'wrong-password': 'Correo o contraseña incorrectos.',
      'user-not-found': 'Correo o contraseña incorrectos.',
      'email-already-in-use': 'Ya existe una cuenta con ese correo.',
      'weak-password': 'La contraseña es muy débil.',
      'network-request-failed': 'Sin conexión. Revisá internet.',
      'too-many-requests': 'Demasiados intentos. Probá en unos minutos.',
      'codigo-desconocido': 'Ocurrió un error al autenticar.',
    };

    Matcher authExceptionCon(String mensaje) => isA<AuthException>()
        .having((error) => error.mensaje, 'mensaje', mensaje);

    for (final entrada in mensajesPorCodigo.entries) {
      test('${entrada.key} se traduce a "${entrada.value}"', () async {
        servicio.error = FirebaseAuthException(code: entrada.key);

        await expectLater(
          repositorio.iniciarConCorreo('a@b.com', 'clave'),
          throwsA(authExceptionCon(entrada.value)),
        );
      });
    }

    test('todos los metodos con try traducen el error', () async {
      servicio.error = FirebaseAuthException(code: 'too-many-requests');
      final llamadas = <Future<void> Function()>[
        () => repositorio.registrarConCorreo('a@b.com', 'clave'),
        () => repositorio.iniciarConCorreo('a@b.com', 'clave'),
        () => repositorio.iniciarConGoogle(),
        () => repositorio.enviarVerificacion(),
        () => repositorio.recargarUsuario(),
        () => repositorio.recuperarContrasena('a@b.com'),
      ];

      for (final llamada in llamadas) {
        await expectLater(
          llamada(),
          throwsA(
            authExceptionCon('Demasiados intentos. Probá en unos minutos.'),
          ),
        );
      }
    });

    test('cerrarSesion no traduce: deja pasar el error de Firebase', () async {
      servicio.error = FirebaseAuthException(code: 'network-request-failed');

      await expectLater(
        repositorio.cerrarSesion(),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('un error que no es de Firebase pasa sin traducir', () async {
      servicio.error = StateError('otro');

      await expectLater(
        repositorio.iniciarConCorreo('a@b.com', 'clave'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
