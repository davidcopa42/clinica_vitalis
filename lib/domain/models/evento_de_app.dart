/// Clase base sellada para los eventos propios de la aplicacion.
sealed class EventoDeApp {
  const EventoDeApp();
}

/// Evento emitido cuando el paciente confirma un nuevo turno.
class TurnoConfirmadoEvento extends EventoDeApp {
  const TurnoConfirmadoEvento({
    required this.especialidad,
    required this.profesional,
    required this.fecha,
  });

  final String especialidad;
  final String profesional;
  final DateTime fecha;
}

/// Evento emitido cuando el paciente cancela un turno.
class TurnoCanceladoEvento extends EventoDeApp {
  const TurnoCanceladoEvento(this.idTurno);

  final int idTurno;
}

/// Evento emitido cuando el paciente registra sus sintomas.
class SintomasRegistradosEvento extends EventoDeApp {
  const SintomasRegistradosEvento({required this.requiereAtencionUrgente});

  final bool requiereAtencionUrgente;
}
