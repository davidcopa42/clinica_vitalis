import '../../../domain/models/paciente.dart';
import '../../../domain/models/turno.dart';

/// Datos que recibe la ruta de turno confirmado.
class DatosTurnoConfirmado {
  const DatosTurnoConfirmado({required this.paciente, required this.turno});

  final Paciente? paciente;
  final Turno turno;
}
