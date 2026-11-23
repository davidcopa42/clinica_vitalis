import 'package:flutter/material.dart';

import '../../core/estado_carga.dart';
import '../view_models/crear_cuenta_view_model.dart';

class CrearCuentaScreen extends StatefulWidget {
  const CrearCuentaScreen({super.key, required this.viewModel});

  /// Lo crea quien abre la pantalla; la pantalla lo descarta al cerrarse.
  final CrearCuentaViewModel viewModel;

  @override
  State<CrearCuentaScreen> createState() => _CrearCuentaScreenState();
}

class _CrearCuentaScreenState extends State<CrearCuentaScreen> {
  static const _longitudMinimaContrasena = 8;

  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();

  CrearCuentaViewModel get _viewModel => widget.viewModel;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _registrar() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _viewModel.registrarUsuario(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        correo: _correoController.text.trim(),
        contrasena: _contrasenaController.text.trim(),
      );

      if (_viewModel.estadoCarga == EstadoCarga.exito && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Cuenta creada. Revisa tu correo electrónico para verificarla.')),
        );
      }
    }
  }

  String? _validarContrasena(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Ingrese su contraseña';
    }
    if (valor.length < _longitudMinimaContrasena) {
      return 'Debe tener al menos 8 caracteres';
    }
    if (!valor.contains(RegExp(r'[a-zA-Z]'))) {
      return 'Debe contener al menos una letra';
    }
    if (!valor.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Cuenta'),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Únete a Clínica Vitalis',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (valor) => valor == null || valor.isEmpty
                            ? 'Ingrese su nombre'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _apellidoController,
                        decoration: const InputDecoration(
                          labelText: 'Apellido',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (valor) => valor == null || valor.isEmpty
                            ? 'Ingrese su apellido'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _correoController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (valor) {
                          if (valor == null || valor.isEmpty) {
                            return 'Ingrese su correo';
                          }
                          if (!valor.contains('@')) {
                            return 'Correo inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contrasenaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: _validarContrasena,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmarContrasenaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Repetir contraseña',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (valor) {
                          if (valor == null || valor.isEmpty) {
                            return 'Confirme su contraseña';
                          }
                          if (valor != _contrasenaController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_viewModel.estadoCarga == EstadoCarga.error)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            _viewModel.mensajeError ?? 'Error desconocido',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _viewModel.estadoCarga == EstadoCarga.cargando
                                  ? null
                                  : _registrar,
                          child: _viewModel.estadoCarga == EstadoCarga.cargando
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Registrarse',
                                  style: TextStyle(fontSize: 16)),
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
