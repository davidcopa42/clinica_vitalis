import 'package:flutter/material.dart';

import '../dimensiones.dart';

/// Boton de ancho completo que muestra un spinner mientras [estaCargando].
class BotonPrincipal extends StatelessWidget {
  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.estaCargando = false,
  });

  final String texto;
  final VoidCallback? onPressed;
  final bool estaCargando;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Dimensiones.altoBoton,
      child: ElevatedButton(
        onPressed: estaCargando ? null : onPressed,
        child: estaCargando
            ? const SizedBox.square(
                dimension: Dimensiones.spinnerChico,
                child: CircularProgressIndicator(
                  strokeWidth: Dimensiones.grosorSpinner,
                ),
              )
            : Text(
                texto,
                style: const TextStyle(fontSize: Dimensiones.textoBoton),
              ),
      ),
    );
  }
}
