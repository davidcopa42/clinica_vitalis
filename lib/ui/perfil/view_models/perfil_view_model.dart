import 'package:clinica_vitalis/data/repositories/auth_repository.dart';
import 'package:clinica_vitalis/data/repositories/perfil_repository.dart';
import 'package:clinica_vitalis/domain/models/obra_social.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/ui/core/formato.dart';
import 'package:flutter/material.dart';

class PerfilViewModel extends ChangeNotifier {
  final PerfilRepository _perfilRepo;
  final AuthRepository _authRepo;

  Paciente? _paciente;
  bool _estaCargando = false;

  PerfilViewModel({
    required PerfilRepository repository,
    required AuthRepository authRepository,
  })  : _perfilRepo = repository,
        _authRepo = authRepository;

  /// Perfil cargado, o null si todavía no se cargó o no existe.
  Paciente? get paciente => _paciente;
  bool get estaCargando => _estaCargando;

  /// Foto de la cuenta, o null si no tiene.
  String? get fotoUrl => _authRepo.usuarioActual?.fotoUrl;

  /// Correo de la cuenta para mostrar.
  String get correoActual =>
      _authRepo.usuarioActual?.correo ?? 'Sin correo electrónico';

  static const _sinDato = 'No registrado';

  String get nombreCompletoTexto =>
      _textoODefecto(_paciente?.nombreCompleto.trim());

  String get dniTexto => _textoODefecto(_paciente?.dni);

  String get telefonoTexto => _textoODefecto(_paciente?.telefono);

  /// Fecha de nacimiento con formato dd/mm/aaaa.
  String get fechaNacimientoTexto {
    final fecha = _paciente?.fechaNacimiento;
    return fecha == null ? _sinDato : formatearFecha(fecha);
  }

  /// Obra social; con el número de afiliado si no es Particular.
  String get obraSocialTexto {
    final obraSocial = _paciente?.obraSocial;
    final numeroAfiliado = _paciente?.numeroAfiliado;
    if (obraSocial == null || obraSocial.isEmpty) return _sinDato;
    if (obraSocial == obraSocialParticular ||
        numeroAfiliado == null ||
        numeroAfiliado.isEmpty) {
      return obraSocial;
    }
    return '$obraSocial (Nº $numeroAfiliado)';
  }

  String _textoODefecto(String? texto) =>
      (texto == null || texto.isEmpty) ? _sinDato : texto;

  Future<void> cargarPerfil(String uid) async {
    if (_paciente == null) {
      _estaCargando = true;
      notifyListeners();
    }

    try {
      _paciente = await _perfilRepo.obtenerPerfil(uid);
    } catch (error) {
      debugPrint('Error al cargar perfil: $error');
    } finally {
      _estaCargando = false;
      notifyListeners();
    }
  }

  /// Guarda el perfil actualizado en el documento [uid] y lo vuelve a cargar.
  Future<void> actualizarPerfil(String uid, Paciente actualizado) async {
    await _perfilRepo.guardarPerfil(uid, actualizado.toMap());
    await cargarPerfil(uid);
  }

  Future<void> cerrarSesion() async {
    await _authRepo.cerrarSesion();
  }
}
