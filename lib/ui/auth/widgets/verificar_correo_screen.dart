import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';
import '../view_models/verificar_correo_view_model.dart';

/// Pantalla que espera a que el paciente verifique su correo.
class VerificarCorreoScreen extends StatefulWidget {
  const VerificarCorreoScreen({
    super.key,
    required this.viewModel,
    required this.onVerificado,
  });

  final VerificarCorreoViewModel viewModel;
  final VoidCallback onVerificado;

  @override
  State<VerificarCorreoScreen> createState() => _VerificarCorreoScreenState();
}

class _VerificarCorreoScreenState extends State<VerificarCorreoScreen> {
  VerificarCorreoViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel
      ..addListener(_reaccionarACambios)
      ..iniciarComprobacion();
  }

  @override
  void dispose() {
    _viewModel
      ..removeListener(_reaccionarACambios)
      ..detenerComprobacion();
    super.dispose();
  }

  void _reaccionarACambios() {
    final aviso = _viewModel.aviso;
    if (aviso != null) {
      _viewModel.limpiarAviso();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(aviso)));
    }
    if (!_viewModel.estaVerificado) return;
    _viewModel.detenerComprobacion();
    widget.onVerificado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar Correo'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Dimensiones.margenPantalla),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.mark_email_unread,
              size: Dimensiones.iconoPortada,
              color: Colors.blue,
            ),
            const SizedBox(height: Dimensiones.separacionExtra),
            const Text(
              'Te enviamos un enlace para verificar tu cuenta.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Dimensiones.textoSubtitulo,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Dimensiones.separacionMedia),
            const Text(
              'Revisa tu bandeja de entrada. La pantalla avanzará sola '
              'cuando toques el enlace.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: Dimensiones.separacionSeccion),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: Dimensiones.separacionSeccion),
            SizedBox(
              height: Dimensiones.altoBoton,
              child: ElevatedButton(
                onPressed: _viewModel.comprobarVerificacion,
                child: const Text('Ya lo verifiqué'),
              ),
            ),
            const SizedBox(height: Dimensiones.separacion),
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) => SizedBox(
                height: Dimensiones.altoBoton,
                child: OutlinedButton(
                  onPressed: _viewModel.puedeReenviar
                      ? _viewModel.reenviarCorreo
                      : null,
                  child: Text(_viewModel.textoBotonReenvio),
                ),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _viewModel.cerrarSesion,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
