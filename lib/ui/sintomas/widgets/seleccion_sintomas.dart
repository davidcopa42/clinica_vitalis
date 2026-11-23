import 'package:flutter/material.dart';

/// Chips para elegir los síntomas.
class SeleccionSintomas extends StatelessWidget {
  const SeleccionSintomas({
    super.key,
    required this.disponibles,
    required this.seleccionados,
    required this.alCambiar,
  });

  final List<String> disponibles;
  final Set<String> seleccionados;
  final ValueChanged<String> alCambiar;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final sintoma in disponibles)
          FilterChip(
            label: Text(sintoma),
            selected: seleccionados.contains(sintoma),
            onSelected: (_) => alCambiar(sintoma),
          ),
      ],
    );
  }
}
