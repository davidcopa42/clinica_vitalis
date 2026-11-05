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

  final String uid, nombre, apellido, correo, telefono, dni;
  final DateTime? fechaNacimiento;
  final String? obraSocial, numeroAfiliado, fotoUrl;

  /// Nombre, apellido, teléfono, DNI y fecha de nacimiento cargados.
  bool get perfilCompleto =>
      nombre.isNotEmpty &&
      apellido.isNotEmpty &&
      telefono.isNotEmpty &&
      dni.isNotEmpty &&
      fechaNacimiento != null;

  String get nombreCompleto => '$nombre $apellido';

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

  factory Paciente.fromMap(Map<String, Object?> mapa) {
    return Paciente(
      uid: mapa['uid'] as String? ?? '',
      nombre: mapa['nombre'] as String? ?? '',
      apellido: mapa['apellido'] as String? ?? '',
      correo: mapa['correo'] as String? ?? '',
      telefono: mapa['telefono'] as String? ?? '',
      dni: mapa['dni'] as String? ?? '',
      fechaNacimiento: mapa['fechaNacimiento'] != null
          ? DateTime.parse(mapa['fechaNacimiento'] as String)
          : null,
      obraSocial: mapa['obraSocial'] as String?,
      numeroAfiliado: mapa['numeroAfiliado'] as String?,
      fotoUrl: mapa['fotoUrl'] as String?,
    );
  }
}
