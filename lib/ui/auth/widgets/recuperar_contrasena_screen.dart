import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';
import '../../core/validadores.dart';
import '../../core/widgets/boton_principal.dart';
import '../../core/widgets/campo_formulario.dart';
import '../view_models/recuperar_contrasena_view_model.dart';

/// Pantalla para pedir el enlace de recuperacion de contrasena.
class RecuperarContrasenaScreen extends StatefulWidget {
  const RecuperarContrasenaScreen({super.key, required this.viewModel});

  static const duracionAviso = Duration(seconds: 4);

  final RecuperarContrasenaViewModel viewModel;

  @override
  State<RecuperarContrasenaScreen> createState() =>
      _RecuperarContrasenaScreenState();
}

class _RecuperarContrasenaScreenState extends State<RecuperarContrasenaScreen> {
  final _claveFormulario = GlobalKey<FormState>();
  final _correoControlador = TextEditingController();

  RecuperarContrasenaViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.reiniciar();
  }

  @override
  void dispose() {
    _correoControlador.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;

    await _viewModel.enviarEnlace(_correoControlador.text.trim());

    if (!mounted || !_viewModel.fueEnviado) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(RecuperarContrasenaViewModel.mensajeEnviado),
        duration: RecuperarContrasenaScreen.duracionAviso,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(Dimensiones.margenPantalla),
        child: Form(
          key: _claveFormulario,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_reset,
                size: Dimensiones.iconoPortada,
                color: Colors.blue,
              ),
              const SizedBox(height: Dimensiones.separacionExtra),
              const Text(
                'Ingresa tu correo electrónico y te enviaremos un enlace '
                'para restablecer tu contraseña.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: Dimensiones.textoBoton),
              ),
              const SizedBox(height: Dimensiones.separacionSeccion),
              CampoFormulario(
                controlador: _correoControlador,
                etiqueta: 'Correo electrónico',
                icono: Icons.email,
                tipoTeclado: TextInputType.emailAddress,
                validador: Validadores.correo,
              ),
              const SizedBox(height: Dimensiones.separacionExtra),
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) => BotonPrincipal(
                  texto: 'Enviar enlace',
                  estaCargando: _viewModel.estaCargando,
                  onPressed: _enviar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
