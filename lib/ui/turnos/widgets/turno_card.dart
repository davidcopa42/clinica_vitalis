import 'package:flutter/material.dart';

import '../../../domain/models/turno.dart';
import '../../core/dimensiones.dart';
import '../../core/formato.dart';

/// Tarjeta con los datos de un turno y el boton para cancelarlo.
class TurnoCard extends StatelessWidget {
  const TurnoCard({
    super.key,
    required this.turno,
    required this.estaCancelando,
    required this.onCancelar,
  });

  final Turno turno;
  final bool estaCancelando;
  final VoidCallback onCancelar;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: Dimensiones.separacionMedia),
      child: Padding(
        padding: const EdgeInsets.all(Dimensiones.separacion),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.blue),
                const SizedBox(width: Dimensiones.separacionMedia),
                Expanded(
                  child: Text(
                    turno.especialidad,
                    style: const TextStyle(
                      fontSize: Dimensiones.textoSubtitulo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensiones.separacionChica),
            Text('Profesional: ${turno.profesional}'),
            const SizedBox(height: Dimensiones.separacionMinima),
            Text('Fecha: ${formatearFecha(turno.fecha)}'),
            Text('Horario: ${turno.horario}'),
            const SizedBox(height: Dimensiones.separacion),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: estaCancelando ? null : onCancelar,
                icon: estaCancelando
                    ? const SizedBox.square(
                        dimension: Dimensiones.textoSubtitulo,
                        child: CircularProgressIndicator(
                          strokeWidth: Dimensiones.grosorSpinner,
                        ),
                      )
                    : const Icon(Icons.cancel_outlined),
                label: const Text('Cancelar turno'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
