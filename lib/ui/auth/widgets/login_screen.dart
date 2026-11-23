import 'package:flutter/material.dart';
import '../../../dependencias.dart';
import '../../core/estado_carga.dart';
import '../view_models/crear_cuenta_view_model.dart';
import '../view_models/login_view_model.dart';
import '../view_models/recuperar_contrasena_view_model.dart';
import 'crear_cuenta_screen.dart';
import 'recuperar_contrasena_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.viewModel,
    required this.dependencias,
  });

  /// Lo crea y lo descarta PuertaSesion.
  final LoginViewModel viewModel;

  /// Para armar los ViewModels de las pantallas que se abren desde acá.
  final Dependencias dependencias;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginViewModel get _viewModel => widget.viewModel;

  /// Crea el ViewModel de Recuperar contraseña y abre la pantalla.
  void _abrirRecuperarContrasena() {
    final viewModel = RecuperarContrasenaViewModel(
      authRepository: widget.dependencias.authRepository,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecuperarContrasenaScreen(viewModel: viewModel),
      ),
    );
  }

  /// Crea el ViewModel de Crear cuenta y abre la pantalla.
  void _abrirCrearCuenta() {
    final viewModel = CrearCuentaViewModel(
      authRepository: widget.dependencias.authRepository,
      perfilRepository: widget.dependencias.perfilRepository,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CrearCuentaScreen(viewModel: viewModel),
      ),
    );
  }

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _intentarLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _viewModel.iniciarSesion(
        _correoController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  void _intentarLoginGoogle() async {
    await _viewModel.iniciarSesionConGoogle();
  }

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
          final estaCargando = _viewModel.estadoCarga == EstadoCarga.cargando;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.local_hospital,
                        size: 80,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Bienvenido de nuevo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _correoController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su correo';
                          }
                          if (!value.contains('@')) {
                            return 'Correo inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su contraseña';
                          }
                          if (value.length < 6) {
                            return 'Debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      if (_viewModel.estadoCarga == EstadoCarga.error)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            _viewModel.mensajeError ?? 'Ocurrió un error',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: estaCargando ? null : _intentarLogin,
                          child: estaCargando
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Ingresar',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: estaCargando ? null : _intentarLoginGoogle,
                          icon: const Icon(Icons.g_mobiledata, size: 32),
                          label: const Text(
                            'Continuar con Google',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed:
                            estaCargando ? null : _abrirRecuperarContrasena,
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      TextButton(
                        onPressed: estaCargando ? null : _abrirCrearCuenta,
                        child: const Text(
                          '¿No tienes cuenta? Regístrate aquí',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
