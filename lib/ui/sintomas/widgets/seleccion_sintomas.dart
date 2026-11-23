import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';

/// Chips para marcar los sintomas que tiene el paciente.
class SeleccionSintomas extends StatelessWidget {
  const SeleccionSintomas({
    super.key,
    required this.sintomas,
    required this.seleccionados,
    required this.onAlternar,
  });

  final List<String> sintomas;
  final Set<String> seleccionados;
  final ValueChanged<String> onAlternar;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Dimensiones.separacionChica,
      runSpacing: Dimensiones.separacionChica,
      children: [
        for (final sintoma in sintomas)
          FilterChip(
            label: Text(sintoma),
            selected: seleccionados.contains(sintoma),
            onSelected: (_) => onAlternar(sintoma),
          ),
      ],
    );
  }
}
