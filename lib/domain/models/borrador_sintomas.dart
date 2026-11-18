/// Síntomas que el paciente cargó pero todavía no registró.
///
/// Se guarda en el dispositivo para no perder lo cargado si sale
/// de la pantalla o cierra la app.
class BorradorSintomas {
  const BorradorSintomas({
    this.sintomas = const [],
    this.descripcion = '',
    this.duracion = 'Hoy',
    this.intensidad = 1,
  });

  final List<String> sintomas;
  final String descripcion;

  /// 'Hoy', '2-3 días' o 'Más de 1 semana'.
  final String duracion;

  /// De 1 a 10.
  final double intensidad;
}
