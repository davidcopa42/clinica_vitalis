import '../../../domain/models/registro_clinico.dart';

/// Textos para mostrar un [RegistroClinico] en pantalla.
extension TextosRegistroClinico on RegistroClinico {
  /// Fecha como d/m/aaaa, sin ceros a la izquierda (por ejemplo 5/9/2026).
  String get fechaTexto => '${fecha.day}/${fecha.month}/${fecha.year}';

  /// Profesional y fecha en dos líneas, para la lista.
  String get resumenTexto => '$profesional\n$fechaTexto';

  /// Nombre del tipo en singular (Análisis, Estudio, Receta).
  String get tipoTexto {
    switch (tipo) {
      case TipoRegistro.analisis:
        return 'Análisis';
      case TipoRegistro.estudio:
        return 'Estudio';
      case TipoRegistro.receta:
        return 'Receta';
    }
  }
}
