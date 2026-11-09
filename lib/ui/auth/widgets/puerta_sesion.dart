import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view_models/sesion_view_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/perfil_repository.dart';
import 'login.dart';
import 'verificar_correo.dart';
import '../../inicio/widgets/inicio.dart';
import '../../perfil/widgets/completar_perfil_screen.dart';

class PuertaSesion extends StatefulWidget {
  const PuertaSesion({super.key});

  @override
  State<PuertaSesion> createState() => _PuertaSesionState();
}

class _PuertaSesionState extends State<PuertaSesion> {
  late final SesionViewModel _sesionVM;

  @override
  void initState() {
    super.initState();
    _sesionVM = SesionViewModel(
      authRepo: AuthRepository(),
      perfilRepo: PerfilRepository(),
    );
  }

  @override
  void dispose() {
    _sesionVM.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _sesionVM,
      builder: (context, child) {
        if (_sesionVM.isCargando) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        switch (_sesionVM.estadoSesion) {
          case EstadoSesion.sinSesion:
            return const LoginScreen();

          case EstadoSesion.correoSinVerificar:
            return VerificarCorreoScreen(
              onVerificado: () async {
                await _sesionVM.recargarYCalcular();
              },
            );

          case EstadoSesion.perfilIncompleto:
            final userActual = FirebaseAuth.instance.currentUser;
            return CompletarPerfilScreen(
              uid: userActual?.uid ?? '',
              correoInicial: userActual?.email ?? '',
              nombreInicial: userActual?.displayName ?? '',
              onPerfilCompletado: () async {
                await _sesionVM.recargarYCalcular();
              },
            );

          case EstadoSesion.lista:
            final paciente = _sesionVM.pacienteActual;
            if (paciente == null) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return InicioPage(
              paciente: paciente,
              sesion: _sesionVM,
            );
        }
      },
    );
  }
}
