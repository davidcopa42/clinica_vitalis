import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view_models/sesion_view_model.dart';
import 'login.dart';
import 'verificar_correo.dart';
import '../../inicio/widgets/inicio.dart';
import '../../perfil/widgets/completar_perfil_screen.dart';

class PuertaSesion extends StatelessWidget {
  const PuertaSesion({super.key});

  @override
  Widget build(BuildContext context) {
    final sesionVM = context.watch<SesionViewModel>();

    return ListenableBuilder(
      listenable: sesionVM,
      builder: (context, child) {
        if (sesionVM.isCargando) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        switch (sesionVM.estadoSesion) {
          case EstadoSesion.sinSesion:
            return const LoginScreen();

          case EstadoSesion.correoSinVerificar:
            return const VerificarCorreoScreen();

          case EstadoSesion.perfilIncompleto:
            final userActual = FirebaseAuth.instance.currentUser;
            return CompletarPerfilScreen(
              uid: userActual?.uid ?? '',
              correoInicial: userActual?.email ?? '',
              nombreInicial: userActual?.displayName ?? '',
            );

          case EstadoSesion.lista:
            final paciente = sesionVM.pacienteActual;
            if (paciente == null) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return InicioPage(
              paciente: paciente,
              sesion: sesionVM,
            );
        }
      },
    );
  }
}
