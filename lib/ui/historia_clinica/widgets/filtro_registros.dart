import 'package:flutter/material.dart';

import '../../../domain/models/registro_clinico.dart';
import 'tipo_registro_ui.dart';

/// Botones para filtrar los registros por tipo (null significa todos).
class FiltroRegistros extends StatelessWidget {
  const FiltroRegistros({
    super.key,
    required this.seleccionado,
    required this.onCambiar,
  });

  final TipoRegistro? seleccionado;
  final ValueChanged<TipoRegistro?> onCambiar;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TipoRegistro?>(
      segments: [
        const ButtonSegment(value: null, label: Text('Todos')),
        for (final tipo in TipoRegistro.values)
          ButtonSegment(value: tipo, label: Text(tipo.nombrePlural)),
      ],
      selected: {seleccionado},
      onSelectionChanged: (seleccion) => onCambiar(seleccion.first),
    );
  }
}
