import 'package:flutter/material.dart';

import '../../core/widgets/vista_cargando.dart';
import '../view_models/estado_sesion.dart';
import '../view_models/sesion_view_model.dart';

/// Muestra la pantalla que corresponde a cada [EstadoSesion].
///
/// Las pantallas se construyen en `main.dart` y llegan ya armadas.
class PuertaSesion extends StatelessWidget {
  const PuertaSesion({
    super.key,
    required this.viewModel,
    required this.pantallaLogin,
    required this.pantallaVerificarCorreo,
    required this.pantallaCompletarPerfil,
    required this.pantallaInicio,
  });

  final SesionViewModel viewModel;
  final Widget pantallaLogin;
  final Widget pantallaVerificarCorreo;
  final Widget pantallaCompletarPerfil;
  final Widget pantallaInicio;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.estaCargando) {
          return const Scaffold(body: VistaCargando());
        }
        return switch (viewModel.estadoSesion) {
          EstadoSesion.sinSesion => pantallaLogin,
          EstadoSesion.correoSinVerificar => pantallaVerificarCorreo,
          EstadoSesion.perfilIncompleto => pantallaCompletarPerfil,
          EstadoSesion.lista => pantallaInicio,
        };
      },
    );
  }
}
