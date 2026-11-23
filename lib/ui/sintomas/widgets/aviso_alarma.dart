import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';

/// Recuadro rojo que indica ir a la guardia.
class AvisoAlarma extends StatelessWidget {
  const AvisoAlarma({super.key});

  static const tamanioIcono = 40.0;
  static const radioBorde = 12.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensiones.separacion),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(radioBorde),
      ),
      child: const Column(
        children: [
          Icon(Icons.warning_amber, color: Colors.red, size: tamanioIcono),
          SizedBox(height: Dimensiones.separacionChica),
          Text(
            'Acudí a la guardia ahora o llamá al 107.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
