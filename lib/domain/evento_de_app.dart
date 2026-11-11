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

/// Evento emitido cuando el paciente cancela un turno.
class TurnoCanceladoEvento extends EventoDeApp {
  final String idTurno;

  TurnoCanceladoEvento(this.idTurno);
}

/// Evento emitido cuando el paciente registra síntomas críticos o normales.
class SintomasRegistradosEvento extends EventoDeApp {
  final bool requiereAtencionUrgente;

  SintomasRegistradosEvento(this.requiereAtencionUrgente);
}