import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';
import '../../core/rutas.dart';
import '../../core/validadores.dart';
import '../../core/widgets/boton_principal.dart';
import '../../core/widgets/campo_formulario.dart';
import '../../core/widgets/mensaje_error.dart';
import '../view_models/login_view_model.dart';
import 'boton_google.dart';

/// Pantalla para iniciar sesion con correo o con Google.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _claveFormulario = GlobalKey<FormState>();
  final _correoControlador = TextEditingController();
  final _contrasenaControlador = TextEditingController();

  LoginViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.reiniciar();
  }

  @override
  void dispose() {
    _correoControlador.dispose();
    _contrasenaControlador.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    await _viewModel.iniciarSesion(
      _correoControlador.text.trim(),
      _contrasenaControlador.text.trim(),
    );
  }

  void _abrir(String ruta) => Navigator.pushNamed(context, ruta);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clínica Vitalis - Iniciar Sesión'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final estaCargando = _viewModel.estaCargando;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensiones.margenPantalla),
              child: Form(
                key: _claveFormulario,
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_hospital,
                      size: Dimensiones.iconoPortada,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: Dimensiones.separacionExtra),
                    const Text(
                      'Bienvenido de nuevo',
                      style: TextStyle(
                        fontSize: Dimensiones.textoTitulo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Dimensiones.separacionSeccion),
                    CampoFormulario(
                      controlador: _correoControlador,
                      etiqueta: 'Correo electrónico',
                      icono: Icons.email,
                      tipoTeclado: TextInputType.emailAddress,
                      validador: Validadores.correo,
                    ),
                    const SizedBox(height: Dimensiones.separacion),
                    CampoFormulario(
                      controlador: _contrasenaControlador,
                      etiqueta: 'Contraseña',
                      icono: Icons.lock,
                      ocultarTexto: true,
                      validador: Validadores.contrasenaIngreso,
                    ),
                    const SizedBox(height: Dimensiones.separacionExtra),
                    if (_viewModel.tieneError)
                      MensajeError(
                        mensaje: _viewModel.mensajeError ?? 'Ocurrió un error',
                      ),
                    BotonPrincipal(
                      texto: 'Ingresar',
                      estaCargando: estaCargando,
                      onPressed: _iniciarSesion,
                    ),
                    const SizedBox(height: Dimensiones.separacionMedia),
                    BotonGoogle(
                      onPressed: estaCargando
                          ? null
                          : _viewModel.iniciarSesionConGoogle,
                    ),
                    const SizedBox(height: Dimensiones.separacion),
                    TextButton(
                      onPressed: estaCargando
                          ? null
                          : () => _abrir(Rutas.recuperarContrasena),
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                    TextButton(
                      onPressed:
                          estaCargando ? null : () => _abrir(Rutas.crearCuenta),
                      child: const Text('¿No tienes cuenta? Regístrate aquí'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
