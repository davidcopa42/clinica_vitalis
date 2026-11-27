/// Datos a medio cargar de la pantalla Registro de síntomas.
///
/// Al leerlo, cada campo es null si no había nada guardado.
class BorradorSintomas {
  const BorradorSintomas({
    this.sintomas,
    this.descripcion,
    this.duracion,
    this.intensidad,
  });

  final List<String>? sintomas;
  final String? descripcion;
  final String? duracion;
  final double? intensidad;
}
