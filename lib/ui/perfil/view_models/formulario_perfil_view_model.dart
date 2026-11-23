import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/perfil_repository.dart';
import '../../../domain/models/paciente.dart';
import '../../core/estado_carga.dart';
import '../../core/formato.dart';
import '../../core/obras_sociales.dart';

/// Estado y comandos del formulario para completar o editar el perfil.
class FormularioPerfilViewModel extends ChangeNotifier {
  FormularioPerfilViewModel({
    required AuthRepository authRepository,
    required PerfilRepository perfilRepository,
  })  : _authRepository = authRepository,
        _perfilRepository = perfilRepository;

  /// Edad con la que se abre el selector de fecha si no hay una cargada.
  static const edadSugerida = 18;
  static final fechaNacimientoMinima = DateTime(1900);

  final AuthRepository _authRepository;
  final PerfilRepository _perfilRepository;

  Paciente? _pacienteBase;
  String _obraSocial = ObrasSociales.particular;
  DateTime? _fechaNacimiento;
  EstadoCarga _estado = EstadoCarga.inicial;
  String? _mensajeError;

  String get nombreInicial => _pacienteBase?.nombre ?? '';
  String get apellidoInicial => _pacienteBase?.apellido ?? '';
  String get dniInicial => _pacienteBase?.dni ?? '';
  String get telefonoInicial => _pacienteBase?.telefono ?? '';
  String get numeroAfiliadoInicial => _pacienteBase?.numeroAfiliado ?? '';

  String get obraSocial => _obraSocial;
  bool get requiereNumeroAfiliado =>
      ObrasSociales.requiereAfiliado(_obraSocial);

  String get fechaNacimientoTexto {
    final fecha = _fechaNacimiento;
    return fecha == null ? '' : formatearFecha(fecha);
  }

  DateTime get fechaInicialSelector {
    final hoy = DateTime.now();
    return _fechaNacimiento ??
        DateTime(hoy.year - edadSugerida, hoy.month, hoy.day);
  }

  DateTime get fechaNacimientoMaxima => DateTime.now();

  bool get estaGuardando => _estado == EstadoCarga.cargando;
  bool get fueGuardado => _estado == EstadoCarga.exito;
  bool get tieneError => _estado == EstadoCarga.error;
  String? get mensajeError => _mensajeError;

  /// Prepara el formulario para un paciente que todavia no completo su perfil.
  ///
  /// Usa el perfil parcial guardado o, si no hay, los datos de la cuenta.
  Future<void> prepararParaCompletar() async {
    final uid = _authRepository.uidActual ?? '';
    Paciente? existente;
    try {
      existente = await _perfilRepository.obtenerPerfil(uid);
    } catch (_) {
      existente = null;
    }
    _cargarPaciente(existente ?? _pacienteDesdeCuenta(uid));
  }

  /// Prepara el formulario con los datos actuales del [paciente].
  void prepararParaEditar(Paciente paciente) => _cargarPaciente(paciente);

  /// Cambia la obra social elegida.
  void seleccionarObraSocial(String? obraSocial) {
    if (obraSocial == null) return;
    _obraSocial = obraSocial;
    notifyListeners();
  }

  /// Cambia la fecha de nacimiento elegida.
  void seleccionarFechaNacimiento(DateTime fecha) {
    _fechaNacimiento = fecha;
    notifyListeners();
  }

  /// Guarda el perfil con los datos ingresados.
  Future<void> guardar({
    required String nombre,
    required String apellido,
    required String dni,
    required String telefono,
    required String numeroAfiliado,
  }) async {
    final base = _pacienteBase;
    if (base == null) return;

    _estado = EstadoCarga.cargando;
    _mensajeError = null;
    notifyListeners();

    try {
      await _perfilRepository.guardarPerfil(
        base.copyWith(
          nombre: nombre,
          apellido: apellido,
          dni: dni,
          telefono: telefono,
          fechaNacimiento: _fechaNacimiento,
          obraSocial: _obraSocial,
          numeroAfiliado: requiereNumeroAfiliado ? numeroAfiliado : '',
        ),
      );
      _estado = EstadoCarga.exito;
    } catch (_) {
      _estado = EstadoCarga.error;
      _mensajeError = 'No se pudo guardar el perfil. Probá de nuevo.';
    } finally {
      notifyListeners();
    }
  }

  /// Cierra la sesion actual.
  Future<void> cerrarSesion() => _authRepository.cerrarSesion();

  void _cargarPaciente(Paciente paciente) {
    _pacienteBase = paciente;
    _obraSocial = ObrasSociales.normalizar(paciente.obraSocial);
    _fechaNacimiento = paciente.fechaNacimiento;
    _estado = EstadoCarga.inicial;
    _mensajeError = null;
    notifyListeners();
  }

  Paciente _pacienteDesdeCuenta(String uid) {
    final partesNombre = (_authRepository.nombreVisible ?? '').split(' ');
    return Paciente(
      uid: uid,
      nombre: partesNombre.first,
      apellido: partesNombre.skip(1).join(' '),
      correo: _authRepository.correoActual ?? '',
    );
  }
}
