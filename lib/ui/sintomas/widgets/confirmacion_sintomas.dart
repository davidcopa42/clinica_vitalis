import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';

/// Mensaje que confirma que los sintomas quedaron registrados.
class ConfirmacionSintomas extends StatelessWidget {
  const ConfirmacionSintomas({super.key, required this.esUrgente});

  /// Si es true, no se recomienda pedir turno (hay que ir a la guardia).
  final bool esUrgente;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensiones.separacionMedia),
      child: esUrgente
          ? const Text(
              'La información quedó registrada en esta sesión.',
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          : const Text(
              'La información quedó registrada en esta sesión. '
              'Te recomendamos solicitar un turno.',
              textAlign: TextAlign.center,
            ),
    );
  }
}
