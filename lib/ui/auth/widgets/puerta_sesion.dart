import 'package:flutter/material.dart';

import '../../../dependencias.dart';
import '../../inicio/widgets/inicio.dart';
import '../../perfil/widgets/completar_perfil_screen.dart';
import '../view_models/sesion_view_model.dart';
import 'login.dart';
import 'verificar_correo.dart';

class PuertaSesion extends StatefulWidget {
  const PuertaSesion({
    super.key,
    required this.sesionViewModel,
    required this.dependencias,
  });

  /// Se crea en `main.dart` y vive mientras vive la app.
  final SesionViewModel sesionViewModel;
  final Dependencias dependencias;

  @override
  State<PuertaSesion> createState() => _PuertaSesionState();
}

class _PuertaSesionState extends State<PuertaSesion> {
  SesionViewModel get _sesionVM => widget.sesionViewModel;

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
            return LoginScreen(dependencias: widget.dependencias);

          case EstadoSesion.correoSinVerificar:
            return VerificarCorreoScreen(
              onVerificado: () async {
                await _sesionVM.recargarYCalcular();
              },
            );

          case EstadoSesion.perfilIncompleto:
            final usuarioActual = _sesionVM.usuarioActual;
            return CompletarPerfilScreen(
              uid: usuarioActual?.uid ?? '',
              correoInicial: usuarioActual?.correo ?? '',
              nombreInicial: usuarioActual?.nombreVisible ?? '',
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
              dependencias: widget.dependencias,
            );
        }
      },
    );
  }
}
