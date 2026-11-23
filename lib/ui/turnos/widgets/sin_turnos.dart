import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';

/// Mensaje que se muestra cuando el paciente no tiene turnos.
class SinTurnos extends StatelessWidget {
  const SinTurnos({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy,
            size: Dimensiones.iconoEstado,
            color: Colors.grey,
          ),
          SizedBox(height: Dimensiones.separacion),
          Text(
            'No tenés turnos',
            style: TextStyle(
              fontSize: Dimensiones.textoSubtitulo,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Dimensiones.separacionChica),
          Text(
            'Cuando solicites un turno, aparecerá acá.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
