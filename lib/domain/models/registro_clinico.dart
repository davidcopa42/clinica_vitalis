/// Tipos de registros disponibles en la historia clinica.
enum TipoRegistro {
  analisis,
  estudio,
  receta,
}

/// Registro de la historia clinica de un paciente.
class RegistroClinico {
  const RegistroClinico({
    required this.tipo,
    required this.titulo,
    required this.fecha,
    required this.profesional,
    required this.detalle,
  });

  /// Crea un registro a partir de un mapa crudo.
  factory RegistroClinico.fromMap(Map<String, Object?> mapa) {
    return RegistroClinico(
      tipo: TipoRegistro.values.byName(mapa['tipo'] as String),
      titulo: mapa['titulo'] as String,
      fecha: DateTime.parse(mapa['fecha'] as String),
      profesional: mapa['profesional'] as String,
      detalle: mapa['detalle'] as String,
    );
  }

  final TipoRegistro tipo;
  final String titulo;
  final DateTime fecha;
  final String profesional;
  final String detalle;

  /// Convierte el registro en un mapa crudo.
  Map<String, Object?> toMap() {
    return {
      'tipo': tipo.name,
      'titulo': titulo,
      'fecha': fecha.toIso8601String(),
      'profesional': profesional,
      'detalle': detalle,
    };
  }
}
