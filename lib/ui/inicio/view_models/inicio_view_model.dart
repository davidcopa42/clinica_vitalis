import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/perfil_repository.dart';
import '../../../domain/models/evento_de_app.dart';
import '../../../domain/models/paciente.dart';
import '../../core/bus_de_eventos.dart';
import 'pestania_inicio.dart';

/// Estado de la pantalla principal: saludo, foto, pestania y avisos.
class InicioViewModel extends ChangeNotifier {
  InicioViewModel({
    required AuthRepository authRepository,
    required PerfilRepository perfilRepository,
    required BusDeEventos busDeEventos,
  })  : _authRepository = authRepository,
        _perfilRepository = perfilRepository {
    _suscripcionEventos = busDeEventos.eventos.listen(_reaccionarAEvento);
  }

  static const nombrePorDefecto = 'Paciente';

  final AuthRepository _authRepository;
  final PerfilRepository _perfilRepository;
  late final StreamSubscription<EventoDeApp> _suscripcionEventos;

  Paciente? _paciente;
  PestaniaInicio _pestania = PestaniaInicio.inicio;
  String? _aviso;

  PestaniaInicio get pestania => _pestania;

  String get saludo {
    final nombre = _paciente?.nombre ?? '';
    return 'Hola, ${nombre.isEmpty ? nombrePorDefecto : nombre}';
  }

  String? get fotoUrl => _authRepository.fotoUrl ?? _paciente?.fotoUrl;

  /// Mensaje para mostrar una sola vez; la vista llama a [limpiarAviso].
  String? get aviso => _aviso;

  /// Carga los datos del paciente con sesion iniciada.
  Future<void> cargar() async {
    _pestania = PestaniaInicio.inicio;
    final uid = _authRepository.uidActual;
    if (uid == null) return;
    try {
      _paciente = await _perfilRepository.obtenerPerfil(uid);
    } catch (_) {
      _paciente = null;
    }
    notifyListeners();
  }

  /// Cambia la pestania visible.
  void seleccionarPestania(PestaniaInicio pestania) {
    _pestania = pestania;
    notifyListeners();
  }

  /// Marca el aviso como mostrado.
  void limpiarAviso() => _aviso = null;

  void _reaccionarAEvento(EventoDeApp evento) {
    if (evento is! TurnoConfirmadoEvento) return;
    _aviso = '¡Éxito! Turno de ${evento.especialidad} registrado.';
    notifyListeners();
  }

  @override
  void dispose() {
    _suscripcionEventos.cancel();
    super.dispose();
  }
}
