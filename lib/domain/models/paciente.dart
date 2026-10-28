class Paciente {
  const Paciente({
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
  });

  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
}