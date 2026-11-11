import 'package:clinica_vitalis/data/repositories/historia_clinica_repository.dart';
import 'package:clinica_vitalis/domain/models/registro_clinico.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';
import 'package:flutter/foundation.dart';

/// Administra los datos y el estado de la historia clínica.
class HistoriaClinicaViewModel extends ChangeNotifier {
  HistoriaClinicaViewModel({
    required HistoriaClinicaRepository repositorio,
  }) : _repositorio = repositorio;

  final HistoriaClinicaRepository _repositorio;

  EstadoCarga _estado = EstadoCarga.inicial;
  List<RegistroClinico> _registros = [];
  TipoRegistro? _filtro;
  String? _mensajeError;
  String _pacienteUid = '';

  EstadoCarga get estado => _estado;

  List<RegistroClinico> get registros => List.unmodifiable(_registros);

  TipoRegistro? get filtro => _filtro;

  String? get mensajeError => _mensajeError;

  /// Registros filtrados según el tipo seleccionado.
  List<RegistroClinico> get registrosFiltrados {
    if (_filtro == null) {
      return List.unmodifiable(_registros);
    }

    return _registros.where((registro) => registro.tipo == _filtro).toList();
  }

  /// Carga los registros clínicos del paciente.
  Future<void> cargar(String pacienteUid) async {
    _pacienteUid = pacienteUid;
    _estado = EstadoCarga.cargando;
    _mensajeError = null;
    notifyListeners();

    try {
      _registros = await _repositorio.obtenerRegistros(pacienteUid);
      _estado = EstadoCarga.exito;
    } catch (_) {
      _mensajeError = 'No se pudo cargar la historia clínica.';
      _estado = EstadoCarga.error;
    } finally {
      notifyListeners();
    }
  }

  /// Reintenta la carga de los registros.
  Future<void> reintentar() async {
    await cargar(_pacienteUid);
  }

  /// Cambia el filtro de registros.
  void cambiarFiltro(TipoRegistro? nuevoFiltro) {
    _filtro = nuevoFiltro;
    notifyListeners();
  }
}
