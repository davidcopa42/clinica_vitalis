import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../view_models/sesion_view_model.dart';

class VerificarCorreoScreen extends StatefulWidget {
  const VerificarCorreoScreen({super.key});

  @override
  State<VerificarCorreoScreen> createState() => _VerificarCorreoScreenState();
}

class _VerificarCorreoScreenState extends State<VerificarCorreoScreen> {
  final AuthRepository _authRepo = AuthRepository();
  bool _puedeReenviar = true;
  int _segundosRestantes = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarTemporizador() {
    setState(() {
      _puedeReenviar = false;
      _segundosRestantes = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosRestantes > 0) {
        setState(() => _segundosRestantes--);
      } else {
        setState(() => _puedeReenviar = true);
        timer.cancel();
      }
    });
  }

  void _reenviarCorreo() async {
    try {
      await _authRepo.enviarVerificacion();
      _iniciarTemporizador();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correo reenviado. Revisa tu bandeja.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reenviar: $e')),
        );
      }
    }
  }

  void _yaVerifique() async {
    await context.read<SesionViewModel>().recargarYCalcular();
  }

  void _cerrarSesion() async {
    await _authRepo.cerrarSesion();
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
              'Revisa tu bandeja de entrada o la carpeta de Spam. Si escribiste mal tu correo, puedes cerrar sesión y registrarte de nuevo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _yaVerifique,
                child: const Text('Ya lo verifiqué',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: _puedeReenviar ? _reenviarCorreo : null,
                child: Text(
                  _puedeReenviar
                      ? 'Reenviar correo'
                      : 'Reenviar disponible en ${_segundosRestantes}s',
                  style: const TextStyle(fontSize: 16),
                ),
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
