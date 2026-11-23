import 'package:flutter/material.dart';
import '../../core/duraciones.dart';
import '../view_models/recuperar_contrasena_view_model.dart';

class RecuperarContrasenaScreen extends StatefulWidget {
  const RecuperarContrasenaScreen({super.key, required this.viewModel});

  /// Lo crea quien abre la pantalla; la pantalla lo descarta al cerrarse.
  final RecuperarContrasenaViewModel viewModel;

  @override
  State<RecuperarContrasenaScreen> createState() =>
      _RecuperarContrasenaScreenState();
}

class _RecuperarContrasenaScreenState extends State<RecuperarContrasenaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  RecuperarContrasenaViewModel get _viewModel => widget.viewModel;

  @override
  void dispose() {
    _correoController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _enviarCorreo() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _viewModel.enviarEnlace(_correoController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Si el correo está registrado, te llegará un enlace'),
            duration: duracionAvisoLargo,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_reset, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
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
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Ingresa tu correo';
                  }
                  if (!valor.contains('@')) {
                    return 'Correo inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, _) {
                    return ElevatedButton(
                      onPressed:
                          _viewModel.estaEnviando ? null : _enviarCorreo,
                      child: _viewModel.estaEnviando
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text('Enviar enlace',
                              style: TextStyle(fontSize: 16)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
