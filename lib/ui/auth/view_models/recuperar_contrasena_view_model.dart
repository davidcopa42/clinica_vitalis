import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../core/estado_carga.dart';

/// Estado y lógica de la pantalla Recuperar contraseña.
class RecuperarContrasenaViewModel extends ChangeNotifier {
  RecuperarContrasenaViewModel({required AuthRepository authRepository})
      : _authRepo = authRepository;

  final AuthRepository _authRepo;

  EstadoCarga _estado = EstadoCarga.inicial;

  EstadoCarga get estado => _estado;
  bool get estaEnviando => _estado == EstadoCarga.cargando;

  /// Pide el enlace de recuperación para el correo.
  ///
  /// Por seguridad no informa si el correo existe: un error solo se
  /// registra y la operación termina igual en [EstadoCarga.exito].
  Future<void> enviarEnlace(String correo) async {
    _estado = EstadoCarga.cargando;
    notifyListeners();

    try {
      await _authRepo.recuperarContrasena(correo);
    } catch (error) {
      debugPrint('Error al recuperar: $error');
    } finally {
      _estado = EstadoCarga.exito;
      notifyListeners();
    }
  }
}
