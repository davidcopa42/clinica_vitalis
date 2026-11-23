/// Clase base sellada para los eventos propios de la aplicación.
sealed class EventoDeApp {}

/// Evento emitido cuando el paciente confirma un nuevo turno.
class TurnoConfirmadoEvento extends EventoDeApp {
  final String especialidad;
  final String profesional;
  final DateTime fecha;

  TurnoConfirmadoEvento({
    required this.especialidad,
    required this.profesional,
    required this.fecha,
  });
}
