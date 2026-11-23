import 'package:flutter/material.dart';

import '../../../domain/models/registro_clinico.dart';

/// Icono y textos con que se muestra cada [TipoRegistro].
extension TipoRegistroUi on TipoRegistro {
  IconData get icono => switch (this) {
        TipoRegistro.analisis => Icons.science,
        TipoRegistro.estudio => Icons.medical_information,
        TipoRegistro.receta => Icons.description,
      };

  /// Nombre en singular, por ejemplo "Análisis".
  String get nombre => switch (this) {
        TipoRegistro.analisis => 'Análisis',
        TipoRegistro.estudio => 'Estudio',
        TipoRegistro.receta => 'Receta',
      };

  /// Nombre en plural para el filtro, por ejemplo "Estudios".
  String get nombrePlural => switch (this) {
        TipoRegistro.analisis => 'Análisis',
        TipoRegistro.estudio => 'Estudios',
        TipoRegistro.receta => 'Recetas',
      };
}
