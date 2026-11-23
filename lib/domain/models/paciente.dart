/// Paciente de la clinica con sus datos personales y de cobertura.
class Paciente {
  const Paciente({
    required this.uid,
    required this.nombre,
    required this.apellido,
    required this.correo,
    this.telefono = '',
    this.dni = '',
    this.fechaNacimiento,
    this.obraSocial,
    this.numeroAfiliado,
    this.fotoUrl,
  });

  /// Crea un paciente a partir de un mapa leido de la base remota.
  factory Paciente.fromMap(Map<String, Object?> mapa) {
    return Paciente(
      uid: mapa['uid'] as String? ?? '',
      nombre: mapa['nombre'] as String? ?? '',
      apellido: mapa['apellido'] as String? ?? '',
      correo: mapa['correo'] as String? ?? '',
      telefono: mapa['telefono'] as String? ?? '',
      dni: mapa['dni'] as String? ?? '',
      fechaNacimiento:
          DateTime.tryParse(mapa['fechaNacimiento'] as String? ?? ''),
      obraSocial: mapa['obraSocial'] as String?,
      numeroAfiliado: mapa['numeroAfiliado'] as String?,
      fotoUrl: mapa['fotoUrl'] as String?,
    );
  }

  final String uid;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final String dni;
  final DateTime? fechaNacimiento;
  final String? obraSocial;
  final String? numeroAfiliado;
  final String? fotoUrl;

  /// Indica si estan cargados nombre, apellido, telefono, DNI y nacimiento.
  bool get perfilCompleto =>
      nombre.isNotEmpty &&
      apellido.isNotEmpty &&
      telefono.isNotEmpty &&
      dni.isNotEmpty &&
      fechaNacimiento != null;

  /// Nombre y apellido separados por un espacio.
  String get nombreCompleto => '$nombre $apellido'.trim();

  /// Devuelve una copia con los campos indicados reemplazados.
  Paciente copyWith({
    String? uid,
    String? nombre,
    String? apellido,
    String? correo,
    String? telefono,
    String? dni,
    DateTime? fechaNacimiento,
    String? obraSocial,
    String? numeroAfiliado,
    String? fotoUrl,
  }) {
    return Paciente(
      uid: uid ?? this.uid,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      dni: dni ?? this.dni,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      obraSocial: obraSocial ?? this.obraSocial,
      numeroAfiliado: numeroAfiliado ?? this.numeroAfiliado,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }

  /// Convierte el paciente en un mapa para guardarlo en la base remota.
  Map<String, Object?> toMap() {
    return {
      'uid': uid,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'telefono': telefono,
      'dni': dni,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'obraSocial': obraSocial,
      'numeroAfiliado': numeroAfiliado,
      'fotoUrl': fotoUrl,
    };
  }
}
