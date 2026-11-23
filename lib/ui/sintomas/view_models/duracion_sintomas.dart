/// Desde cuando tiene sintomas el paciente.
enum DuracionSintomas {
  hoy(valor: 'Hoy', etiqueta: 'Hoy'),
  dosATresDias(valor: '2 a 3 días', etiqueta: '2-3 días'),
  masDeUnaSemana(valor: 'Más de una semana', etiqueta: 'Más de 1 semana');

  const DuracionSintomas({required this.valor, required this.etiqueta});

  /// Texto que se guarda en el borrador.
  final String valor;

  /// Texto corto para mostrar en pantalla.
  final String etiqueta;

  /// Devuelve la duracion cuyo [valor] coincide, o [hoy] si no hay.
  static DuracionSintomas desdeValor(String? valor) => values.firstWhere(
        (duracion) => duracion.valor == valor,
        orElse: () => hoy,
      );
}
