/// Obras sociales y prepagas que acepta la clinica.
abstract final class ObrasSociales {
  static const particular = 'Particular';

  static const disponibles = [
    particular,
    'OSDE',
    'Swiss Medical',
    'Galeno',
    'PAMI',
    'IOMA',
    'Otra',
  ];

  /// Devuelve [obraSocial] si es una opcion valida, o [particular].
  static String normalizar(String? obraSocial) =>
      disponibles.contains(obraSocial) ? obraSocial! : particular;

  /// Indica si [obraSocial] necesita numero de afiliado.
  static bool requiereAfiliado(String obraSocial) => obraSocial != particular;
}
