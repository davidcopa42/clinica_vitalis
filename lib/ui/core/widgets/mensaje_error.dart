import 'package:flutter/material.dart';

import '../dimensiones.dart';

/// Texto de error en rojo, centrado, para mostrar debajo de un formulario.
class MensajeError extends StatelessWidget {
  const MensajeError({super.key, required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensiones.separacion),
      child: Text(
        mensaje,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
