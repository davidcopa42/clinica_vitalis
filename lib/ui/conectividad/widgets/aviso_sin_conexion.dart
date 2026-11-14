import 'package:flutter/material.dart';
import '../view_models/conectividad_view_model.dart';

class AvisoSinConexion extends StatelessWidget {
  final ConectividadViewModel viewModel;

  const AvisoSinConexion({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        // Si hay conexión, no mostramos nada (retornamos un contenedor vacío)
        if (viewModel.hayConexion) {
          return const SizedBox.shrink();
        }

        // Si NO hay conexión, mostramos la franja de alerta arriba
        return Container(
          color: Colors.red[700],
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Sin conexión. Los cambios se guardarán localmente.',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}