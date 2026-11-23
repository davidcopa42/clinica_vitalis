import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/perfil_repository.dart';
import '../../../domain/models/paciente.dart';
import '../../core/estado_carga.dart';
import '../../core/formato.dart';
import '../../core/obras_sociales.dart';

/// Estado y comandos de la pantalla de perfil del paciente.
class PerfilViewModel extends ChangeNotifier {
  PerfilViewModel({
    required AuthRepository authRepository,
    required PerfilRepository perfilRepository,
  })  : _authRepository = authRepository,
        _perfilRepository = perfilRepository;

  final AuthRepository _authRepository;
  final PerfilRepository _perfilRepository;

  EstadoCarga _estado = EstadoCarga.inicial;
  Paciente? _paciente;

  EstadoCarga get estado => _estado;
  Paciente? get paciente => _paciente;
  bool get estaCargando => _estado == EstadoCarga.cargando;

  String get correoTexto =>
      _authRepository.correoActual ?? 'Sin correo electrónico';

  String? get fotoUrl => _authRepository.fotoUrl ?? _paciente?.fotoUrl;

  String get nombreCompletoTexto => textoOpcional(_paciente?.nombreCompleto);

  String get dniTexto => textoOpcional(_paciente?.dni);

  String get telefonoTexto => textoOpcional(_paciente?.telefono);

  String get nacimientoTexto {
    final fecha = _paciente?.fechaNacimiento;
    return fecha == null ? textoNoRegistrado : formatearFecha(fecha);
  }

  String get obraSocialTexto {
    final obraSocial = _paciente?.obraSocial;
    final afiliado = _paciente?.numeroAfiliado ?? '';
    if (obraSocial == null || obraSocial.isEmpty) return textoNoRegistrado;
    if (!ObrasSociales.requiereAfiliado(obraSocial) || afiliado.isEmpty) {
      return obraSocial;
    }
    return '$obraSocial (Nº $afiliado)';
  }

  /// Carga el perfil del paciente con sesion iniciada.
  Future<void> cargar() async {
    final uid = _authRepository.uidActual;
    if (uid == null) return;

    _estado = EstadoCarga.cargando;
    notifyListeners();

    try {
      _paciente = await _perfilRepository.obtenerPerfil(uid);
      _estado = EstadoCarga.exito;
    } catch (_) {
      _estado = EstadoCarga.error;
    } finally {
      notifyListeners();
    }
  }

  /// Cierra la sesion actual.
  Future<void> cerrarSesion() async {
    await _authRepository.cerrarSesion();
    _paciente = null;
    _estado = EstadoCarga.inicial;
  }
}
