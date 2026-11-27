import 'package:flutter/material.dart';

/// Aviso rojo que indica ir a la guardia ante signos de alarma.
class AvisoAlarma extends StatelessWidget {
  const AvisoAlarma({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.warning_amber,
            color: Colors.red,
            size: 40,
          ),
          SizedBox(height: 8),
          Text(
            'Acudí a la guardia ahora o llamá al 107.',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
