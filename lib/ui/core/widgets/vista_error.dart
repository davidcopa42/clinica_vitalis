import 'package:flutter/material.dart';

import '../dimensiones.dart';

/// Mensaje de error centrado con un boton para reintentar.
class VistaError extends StatelessWidget {
  const VistaError({
    super.key,
    required this.mensaje,
    required this.onReintentar,
  });

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensiones.margenPantalla),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: Dimensiones.iconoEstado,
              color: Colors.red,
            ),
            const SizedBox(height: Dimensiones.separacion),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: Dimensiones.separacion),
            ElevatedButton(
              onPressed: onReintentar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
