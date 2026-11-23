import 'package:flutter/material.dart';

import '../../../data/repositories/auth_repositorio_firebase.dart';
import '../../../data/services/auth_service.dart';
import '../view_models/verificar_correo_view_model.dart';

class VerificarCorreoScreen extends StatefulWidget {
  final VoidCallback onVerificado;

  const VerificarCorreoScreen({super.key, required this.onVerificado});

  @override
  State<VerificarCorreoScreen> createState() => _VerificarCorreoScreenState();
}

class _VerificarCorreoScreenState extends State<VerificarCorreoScreen> {
  late final VerificarCorreoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = VerificarCorreoViewModel(
      authRepository: AuthRepositorioFirebase(authService: AuthService()),
      alVerificarCorreo: widget.onVerificado,
    );
    _viewModel.iniciarVerificacionAutomatica();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _reenviarCorreo() async {
    final error = await _viewModel.reenviarCorreo();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Correo reenviado. Revisa tu bandeja.'),
      ),
    );
  }

  void _yaVerifiqueManual() {
    _viewModel.comprobarVerificacion();
  }

  void _cerrarSesion() async {
    await _viewModel.cerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar Correo'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.mark_email_unread, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Te enviamos un enlace para verificar tu cuenta.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Revisa tu bandeja de entrada. La pantalla avanzará sola cuando toques el enlace.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const Center(
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _yaVerifiqueManual,
                child: const Text('Ya lo verifiqué (Forzar avance)',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  return OutlinedButton(
                    onPressed:
                        _viewModel.puedeReenviar ? _reenviarCorreo : null,
                    child: Text(
                      _viewModel.puedeReenviar
                          ? 'Reenviar correo'
                          : 'Reenviar disponible en '
                              '${_viewModel.segundosRestantes}s',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _cerrarSesion,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Cerrar sesión',
                  style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
