import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';
import '../view_models/conectividad_view_model.dart';

/// Franja roja que aparece cuando no hay conexion a internet.
class AvisoSinConexion extends StatelessWidget {
  const AvisoSinConexion({super.key, required this.viewModel});

  static const tamanioIcono = 18.0;

  final ConectividadViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.hayConexion) return const SizedBox.shrink();

        return Container(
          color: Colors.red[700],
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: Dimensiones.separacionChica,
            horizontal: Dimensiones.separacion,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: tamanioIcono),
              SizedBox(width: Dimensiones.separacionChica),
              Flexible(
                child: Text(
                  'Sin conexión. Los cambios se guardarán localmente.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
