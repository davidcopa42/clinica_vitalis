import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/perfil_repository.dart';
import '../../../domain/models/obra_social.dart';
import '../../../domain/models/paciente.dart';
import '../../core/estado_carga.dart';

/// Estado y lógica de la pantalla Completar perfil.
class CompletarPerfilViewModel extends ChangeNotifier {
  CompletarPerfilViewModel({
    required PerfilRepository perfilRepository,
    required AuthRepository authRepository,
  })  : _perfilRepo = perfilRepository,
        _authRepo = authRepository;

  final PerfilRepository _perfilRepo;
  final AuthRepository _authRepo;

  EstadoCarga _estado = EstadoCarga.inicial;

  EstadoCarga get estado => _estado;
  bool get estaGuardando => _estado == EstadoCarga.cargando;

  /// Separa el nombre de la cuenta: la primera palabra es el nombre y el
  /// resto, el apellido.
  ({String nombre, String apellido}) separarNombreInicial(
    String nombreInicial,
  ) {
    final partesNombre = nombreInicial.split(' ');
    return (
      nombre: partesNombre.isNotEmpty ? partesNombre.first : '',
      apellido:
          partesNombre.length > 1 ? partesNombre.sublist(1).join(' ') : '',
    );
  }

  /// Guarda el perfil completo del paciente.
  ///
  /// Devuelve null si salió bien, o el mensaje de error para mostrar.
  Future<String?> guardarPerfil({
    required String uid,
    required String nombre,
    required String apellido,
    required String correo,
    required String dni,
    required DateTime? fechaNacimiento,
    required String telefono,
    required String obraSocial,
    required String numeroAfiliado,
  }) async {
    _estado = EstadoCarga.cargando;
    notifyListeners();

    try {
      final paciente = Paciente(
        uid: uid,
        nombre: nombre.trim(),
        apellido: apellido.trim(),
        correo: correo,
        dni: dni.trim(),
        fechaNacimiento: fechaNacimiento,
        telefono: telefono.trim(),
        obraSocial: obraSocial,
        numeroAfiliado:
            obraSocial == obraSocialParticular ? '' : numeroAfiliado.trim(),
      );
      await _perfilRepo.guardarPerfil(uid, paciente.toMap());
      _estado = EstadoCarga.exito;
      return null;
    } catch (error) {
      _estado = EstadoCarga.error;
      return 'Error al guardar el perfil: $error';
    } finally {
      notifyListeners();
    }
  }

  Future<void> cerrarSesion() async {
    await _authRepo.cerrarSesion();
  }
}
