import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repositorio_firebase.dart';
import '../../../data/services/auth_service.dart';
import '../view_models/recuperar_contrasena_view_model.dart';

class RecuperarPasswordScreen extends StatefulWidget {
  const RecuperarPasswordScreen({super.key});

  @override
  State<RecuperarPasswordScreen> createState() =>
      _RecuperarPasswordScreenState();
}

class _RecuperarPasswordScreenState extends State<RecuperarPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  late final RecuperarContrasenaViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RecuperarContrasenaViewModel(
      authRepository: AuthRepositorioFirebase(authService: AuthService()),
    );
  }

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
            duration: Duration(seconds: 4),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu correo';
                  }
                  if (!value.contains('@')) {
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
