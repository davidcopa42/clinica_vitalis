import 'package:flutter/material.dart';

/// Confirma el registro y recomienda pedir un turno.
class RecomendacionTurno extends StatelessWidget {
  const RecomendacionTurno({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 12),
      child: Text(
        'La información quedó registrada en esta sesión. '
        'Te recomendamos solicitar un turno.',
        textAlign: TextAlign.center,
      ),
    );
  }
}
