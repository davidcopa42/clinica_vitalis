import 'package:flutter/material.dart';

import '../../../domain/models/registro_clinico.dart';

/// Botones para filtrar la historia clínica por tipo de registro.
class FiltroTiposRegistro extends StatelessWidget {
  const FiltroTiposRegistro({
    super.key,
    required this.filtro,
    required this.alCambiar,
  });

  /// Tipo elegido, o null para mostrar todos.
  final TipoRegistro? filtro;
  final ValueChanged<TipoRegistro?> alCambiar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SegmentedButton<TipoRegistro?>(
        segments: const [
          ButtonSegment(
            value: null,
            label: Text('Todos'),
          ),
          ButtonSegment(
            value: TipoRegistro.analisis,
            label: Text('Análisis'),
          ),
          ButtonSegment(
            value: TipoRegistro.estudio,
            label: Text('Estudios'),
          ),
          ButtonSegment(
            value: TipoRegistro.receta,
            label: Text('Recetas'),
          ),
        ],
        selected: {filtro},
        onSelectionChanged: (seleccion) => alCambiar(seleccion.first),
      ),
    );
  }
}
