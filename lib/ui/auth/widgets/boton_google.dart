import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';

/// Boton para continuar con una cuenta de Google.
class BotonGoogle extends StatelessWidget {
  const BotonGoogle({super.key, required this.onPressed});

  static const tamanioIcono = 32.0;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Dimensiones.altoBoton,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.g_mobiledata, size: tamanioIcono),
        label: const Text(
          'Continuar con Google',
          style: TextStyle(fontSize: Dimensiones.textoBoton),
        ),
      ),
    );
  }
}
