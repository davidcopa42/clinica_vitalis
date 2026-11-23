import 'package:flutter/material.dart';

import '../../../dependencias.dart';
import '../../conectividad/view_models/conectividad_view_model.dart';
import '../../inicio/view_models/inicio_view_model.dart';
import '../../inicio/widgets/inicio.dart';
import '../../perfil/view_models/completar_perfil_view_model.dart';
import '../../perfil/view_models/perfil_view_model.dart';
import '../../perfil/widgets/completar_perfil_screen.dart';
import '../view_models/login_view_model.dart';
import '../view_models/sesion_view_model.dart';
import '../view_models/verificar_correo_view_model.dart';
import 'login.dart';
import 'verificar_correo.dart';

/// Lo que la puerta muestra en cada momento.
enum _Pantalla { cargando, login, verificarCorreo, completarPerfil, inicio }

class PuertaSesion extends StatefulWidget {
  const PuertaSesion({
    super.key,
    required this.sesionViewModel,
    required this.dependencias,
  });

  /// Se crea en `main.dart` y vive mientras vive la app.
  final SesionViewModel sesionViewModel;
  final Dependencias dependencias;

  @override
  State<PuertaSesion> createState() => _PuertaSesionState();
}

class _PuertaSesionState extends State<PuertaSesion> {
  SesionViewModel get _sesionVM => widget.sesionViewModel;

  _Pantalla? _pantalla;

  // ViewModels de la pantalla que se está mostrando. Los crea y los
  // descarta esta puerta, nunca la pantalla.
  LoginViewModel? _loginViewModel;
  VerificarCorreoViewModel? _verificarCorreoViewModel;
  CompletarPerfilViewModel? _completarPerfilViewModel;
  InicioViewModel? _inicioViewModel;
  PerfilViewModel? _perfilViewModel;
  ConectividadViewModel? _conectividadViewModel;

  @override
  void initState() {
    super.initState();
    _actualizarPantalla();
    // Se registra antes que el ListenableBuilder de build, así los
    // ViewModels nuevos ya existen cuando se redibuja.
    _sesionVM.addListener(_actualizarPantalla);
  }

  @override
  void dispose() {
    _sesionVM.removeListener(_actualizarPantalla);
    _descartar(_tomarViewModelsActuales());
    super.dispose();
  }

  _Pantalla _calcularPantalla() {
    if (_sesionVM.isCargando) return _Pantalla.cargando;

    switch (_sesionVM.estadoSesion) {
      case EstadoSesion.sinSesion:
        return _Pantalla.login;
      case EstadoSesion.correoSinVerificar:
        return _Pantalla.verificarCorreo;
      case EstadoSesion.perfilIncompleto:
        return _Pantalla.completarPerfil;
      case EstadoSesion.lista:
        return _sesionVM.pacienteActual == null
            ? _Pantalla.cargando
            : _Pantalla.inicio;
    }
  }

  /// Cuando cambia lo que se muestra, crea los ViewModels de la pantalla
  /// nueva y descarta los de la anterior. Corre fuera de build.
  void _actualizarPantalla() {
    final nueva = _calcularPantalla();
    if (nueva == _pantalla) return;

    final anteriores = _tomarViewModelsActuales();
    _crearViewModelsPara(nueva);
    _pantalla = nueva;

    // Se descartan después del próximo frame, cuando la pantalla anterior
    // ya se desmontó y dejó de escucharlos.
    if (anteriores.isNotEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _descartar(anteriores));
    }
  }

  void _crearViewModelsPara(_Pantalla pantalla) {
    final dependencias = widget.dependencias;

    switch (pantalla) {
      case _Pantalla.cargando:
        break;
      case _Pantalla.login:
        _loginViewModel = LoginViewModel(
          authRepository: dependencias.authRepository,
          perfilRepository: dependencias.perfilRepository,
        );
      case _Pantalla.verificarCorreo:
        _verificarCorreoViewModel = VerificarCorreoViewModel(
          authRepository: dependencias.authRepository,
          alVerificarCorreo: _sesionVM.recargarYCalcular,
        );
      case _Pantalla.completarPerfil:
        _completarPerfilViewModel = CompletarPerfilViewModel(
          perfilRepository: dependencias.perfilRepository,
          authRepository: dependencias.authRepository,
        );
      case _Pantalla.inicio:
        _inicioViewModel = InicioViewModel(
          busDeEventos: dependencias.busDeEventos,
          authRepository: dependencias.authRepository,
          paciente: _sesionVM.pacienteActual!,
        );
        _perfilViewModel = PerfilViewModel(
          repository: dependencias.perfilRepository,
          authRepository: dependencias.authRepository,
        );
        _conectividadViewModel = ConectividadViewModel(
          repositorio: dependencias.conectividadRepository,
        );
    }
  }

  /// Devuelve los ViewModels actuales y deja las referencias en null.
  List<ChangeNotifier> _tomarViewModelsActuales() {
    final actuales = <ChangeNotifier?>[
      _loginViewModel,
      _verificarCorreoViewModel,
      _completarPerfilViewModel,
      _inicioViewModel,
      _perfilViewModel,
      _conectividadViewModel,
    ].whereType<ChangeNotifier>().toList();

    _loginViewModel = null;
    _verificarCorreoViewModel = null;
    _completarPerfilViewModel = null;
    _inicioViewModel = null;
    _perfilViewModel = null;
    _conectividadViewModel = null;

    return actuales;
  }

  void _descartar(List<ChangeNotifier> viewModels) {
    for (final viewModel in viewModels) {
      viewModel.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _sesionVM,
      builder: (context, child) {
        switch (_pantalla!) {
          case _Pantalla.cargando:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );

          case _Pantalla.login:
            return LoginScreen(
              viewModel: _loginViewModel!,
              dependencias: widget.dependencias,
            );

          case _Pantalla.verificarCorreo:
            return VerificarCorreoScreen(
              viewModel: _verificarCorreoViewModel!,
            );

          case _Pantalla.completarPerfil:
            final usuarioActual = _sesionVM.usuarioActual;
            return CompletarPerfilScreen(
              viewModel: _completarPerfilViewModel!,
              uid: usuarioActual?.uid ?? '',
              correoInicial: usuarioActual?.correo ?? '',
              nombreInicial: usuarioActual?.nombreVisible ?? '',
              onPerfilCompletado: () async {
                await _sesionVM.recargarYCalcular();
              },
            );

          case _Pantalla.inicio:
            return InicioPage(
              paciente: _sesionVM.pacienteActual!,
              sesion: _sesionVM,
              dependencias: widget.dependencias,
              inicioViewModel: _inicioViewModel!,
              perfilViewModel: _perfilViewModel!,
              conectividadViewModel: _conectividadViewModel!,
            );
        }
      },
    );
  }
}
