import 'package:flutter/material.dart';

import '../../../domain/models/turno.dart';

/// Dialogo que pide confirmar la cancelacion de un turno.
class DialogoCancelarTurno extends StatelessWidget {
  const DialogoCancelarTurno({super.key, required this.turno});

  final Turno turno;

  /// Muestra el dialogo y devuelve true si el usuario confirma.
  static Future<bool> confirmar(BuildContext context, Turno turno) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => DialogoCancelarTurno(turno: turno),
    );
    return confirmado ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancelar turno'),
      content: Text(
        '¿Querés cancelar tu turno de ${turno.especialidad} '
        'con ${turno.profesional}?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('No'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Cancelar turno'),
        ),
      ],
    );
  }
}
