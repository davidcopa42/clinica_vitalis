import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../data/repositories/auth_repository.dart';

class VerificarCorreoScreen extends StatefulWidget {
  final VoidCallback onVerificado;

  const VerificarCorreoScreen({super.key, required this.onVerificado});

  @override
  State<VerificarCorreoScreen> createState() => _VerificarCorreoScreenState();
}

class _VerificarCorreoScreenState extends State<VerificarCorreoScreen> {
  final AuthRepository _authRepo = AuthRepository();

  bool _puedeReenviar = true;
  int _segundosRestantes = 0;

  Timer? _timerReenvio;
  Timer? _timerVerificacionAutomatica;

  @override
  void initState() {
    super.initState();

    _timerVerificacionAutomatica = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _chequearVerificacion(),
    );
  }

  @override
  void dispose() {
    _timerReenvio?.cancel();
    _timerVerificacionAutomatica?.cancel();
    super.dispose();
  }

  // Este es el método mágico que avanza solo
  Future<void> _chequearVerificacion() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();

    if (user?.emailVerified ?? false) {
      _timerVerificacionAutomatica?.cancel();
      widget.onVerificado();
    }
  }

  void _iniciarTemporizadorReenvio() {
    setState(() {
      _puedeReenviar = false;
      _segundosRestantes = 60;
    });

    _timerReenvio = Timer.periodic(const Duration(seconds: 1), (timer) {
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
      _iniciarTemporizadorReenvio();
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

  void _yaVerifiqueManual() {
    _chequearVerificacion();
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
