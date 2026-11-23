import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/historia_clinica_repository.dart';
import '../../../domain/models/registro_clinico.dart';
import '../../core/estado_carga.dart';

/// Estado y comandos de la pantalla de historia clinica.
class HistoriaClinicaViewModel extends ChangeNotifier {
  HistoriaClinicaViewModel({
    required HistoriaClinicaRepository historiaClinicaRepository,
    required AuthRepository authRepository,
  })  : _historiaClinicaRepository = historiaClinicaRepository,
        _authRepository = authRepository;

  final HistoriaClinicaRepository _historiaClinicaRepository;
  final AuthRepository _authRepository;

  EstadoCarga _estado = EstadoCarga.inicial;
  List<RegistroClinico> _registros = [];
  TipoRegistro? _filtro;
  String? _mensajeError;

  EstadoCarga get estado => _estado;
  TipoRegistro? get filtro => _filtro;
  String? get mensajeError => _mensajeError;

  /// Registros del tipo seleccionado, o todos si no hay filtro.
  List<RegistroClinico> get registrosFiltrados => List.unmodifiable(
        _filtro == null
            ? _registros
            : _registros.where((registro) => registro.tipo == _filtro),
      );

  bool get hayRegistrosFiltrados => registrosFiltrados.isNotEmpty;

  /// Carga los registros clinicos del paciente con sesion iniciada.
  Future<void> cargar() async {
    final uid = _authRepository.uidActual;
    if (uid == null) return;

    _estado = EstadoCarga.cargando;
    _mensajeError = null;
    notifyListeners();

    try {
      _registros = await _historiaClinicaRepository.obtenerRegistros(uid);
      _estado = EstadoCarga.exito;
    } catch (_) {
      _mensajeError = 'No se pudo cargar la historia clínica.';
      _estado = EstadoCarga.error;
    } finally {
      notifyListeners();
    }
  }

  /// Cambia el filtro de registros.
  void cambiarFiltro(TipoRegistro? nuevoFiltro) {
    _filtro = nuevoFiltro;
    notifyListeners();
  }
}
