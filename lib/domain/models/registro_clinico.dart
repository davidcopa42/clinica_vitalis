/// Tipos de registros disponibles en la historia clínica.
enum TipoRegistro {
  analisis,
  estudio,
  receta,
}

/// Representa un registro de la historia clínica de un paciente.
class RegistroClinico {
  const RegistroClinico({
    required this.tipo,
    required this.titulo,
    required this.fecha,
    required this.profesional,
    required this.detalle,
  });

  final TipoRegistro tipo;
  final String titulo;
  final DateTime fecha;
  final String profesional;
  final String detalle;
}
