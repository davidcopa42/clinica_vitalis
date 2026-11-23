/// Datos parciales del registro de sintomas que el paciente esta cargando.
class BorradorSintomas {
  const BorradorSintomas({
    this.sintomas = const [],
    this.descripcion,
    this.duracion,
    this.intensidad,
  });

  final List<String> sintomas;
  final String? descripcion;
  final String? duracion;
  final double? intensidad;
}
