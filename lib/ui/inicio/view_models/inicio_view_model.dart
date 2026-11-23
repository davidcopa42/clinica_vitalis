import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/bus_de_eventos.dart';
import '../../../domain/models/evento_de_app.dart';
import '../../../domain/models/paciente.dart';

/// Estado y lógica de la pantalla Inicio.
///
/// Escucha el bus de eventos y deja un aviso pendiente para que la
/// pantalla lo muestre cuando se confirma un turno.
class InicioViewModel extends ChangeNotifier {
  InicioViewModel({
    required BusDeEventos busDeEventos,
    required AuthRepository authRepository,
    required Paciente paciente,
  })  : _authRepo = authRepository,
        _paciente = paciente {
    _suscripcionEventos = busDeEventos.stream.listen(_manejarEvento);
  }

  final AuthRepository _authRepo;
  final Paciente _paciente;
  late final StreamSubscription<EventoDeApp> _suscripcionEventos;

  String? _avisoPendiente;

  /// Mensaje que la pantalla tiene que mostrar, o null si no hay ninguno.
  String? get avisoPendiente => _avisoPendiente;

  /// Nombre para el saludo; 'Paciente' si todavía no tiene nombre.
  String get nombreUsuario =>
      _paciente.nombre.isNotEmpty ? _paciente.nombre : 'Paciente';

  /// Saludo de la pantalla, por ejemplo "Hola, Ana".
  String get saludo => 'Hola, $nombreUsuario';

  /// Foto de la cuenta; si no tiene, la del perfil del paciente.
  String? get fotoUrl => _authRepo.usuarioActual?.fotoUrl ?? _paciente.fotoUrl;

  /// Foto para el avatar, o null si no hay ninguna que mostrar.
  String? get fotoParaMostrar {
    final foto = fotoUrl;
    return (foto == null || foto.isEmpty) ? null : foto;
  }

  /// El perfil se puede abrir solo si el paciente está identificado.
  bool get puedeAbrirPerfil => _paciente.uid.isNotEmpty;

  /// La pantalla lo llama después de mostrar el aviso.
  void descartarAviso() {
    _avisoPendiente = null;
  }

  void _manejarEvento(EventoDeApp evento) {
    if (evento is TurnoConfirmadoEvento) {
      _avisoPendiente = '¡Éxito! Turno de ${evento.especialidad} registrado.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _suscripcionEventos.cancel();
    super.dispose();
  }
}
