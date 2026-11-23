import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';
import '../../core/validadores.dart';
import '../../core/widgets/boton_principal.dart';
import '../../core/widgets/campo_formulario.dart';
import '../../core/widgets/mensaje_error.dart';
import '../view_models/crear_cuenta_view_model.dart';

/// Pantalla para crear una cuenta con correo y contrasena.
class CrearCuentaScreen extends StatefulWidget {
  const CrearCuentaScreen({super.key, required this.viewModel});

  final CrearCuentaViewModel viewModel;

  @override
  State<CrearCuentaScreen> createState() => _CrearCuentaScreenState();
}

class _CrearCuentaScreenState extends State<CrearCuentaScreen> {
  final _claveFormulario = GlobalKey<FormState>();
  final _nombreControlador = TextEditingController();
  final _apellidoControlador = TextEditingController();
  final _correoControlador = TextEditingController();
  final _contrasenaControlador = TextEditingController();
  final _confirmacionControlador = TextEditingController();

  CrearCuentaViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.reiniciar();
  }

  @override
  void dispose() {
    _nombreControlador.dispose();
    _apellidoControlador.dispose();
    _correoControlador.dispose();
    _contrasenaControlador.dispose();
    _confirmacionControlador.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;

    await _viewModel.registrarUsuario(
      nombre: _nombreControlador.text.trim(),
      apellido: _apellidoControlador.text.trim(),
      correo: _correoControlador.text.trim(),
      contrasena: _contrasenaControlador.text.trim(),
    );

    if (!mounted || !_viewModel.fueRegistrado) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Cuenta creada. Revisa tu correo electrónico para verificarla.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Nueva Cuenta')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensiones.margenPantalla),
              child: Form(
                key: _claveFormulario,
                child: Column(
                  children: [
                    const Text(
                      'Únete a Clínica Vitalis',
                      style: TextStyle(
                        fontSize: Dimensiones.textoTitulo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Dimensiones.separacionExtra),
                    CampoFormulario(
                      controlador: _nombreControlador,
                      etiqueta: 'Nombre',
                      icono: Icons.person,
                      validador: Validadores.requerido('Ingresá tu nombre'),
                    ),
                    const SizedBox(height: Dimensiones.separacion),
                    CampoFormulario(
                      controlador: _apellidoControlador,
                      etiqueta: 'Apellido',
                      icono: Icons.person_outline,
                      validador: Validadores.requerido('Ingresá tu apellido'),
                    ),
                    const SizedBox(height: Dimensiones.separacion),
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
                      validador: Validadores.contrasenaNueva,
                    ),
                    const SizedBox(height: Dimensiones.separacion),
                    CampoFormulario(
                      controlador: _confirmacionControlador,
                      etiqueta: 'Repetir contraseña',
                      icono: Icons.lock_outline,
                      ocultarTexto: true,
                      validador: Validadores.confirmacion(
                        () => _contrasenaControlador.text,
                      ),
                    ),
                    const SizedBox(height: Dimensiones.separacionGrande),
                    if (_viewModel.tieneError)
                      MensajeError(
                        mensaje: _viewModel.mensajeError ?? 'Error desconocido',
                      ),
                    BotonPrincipal(
                      texto: 'Registrarse',
                      estaCargando: _viewModel.estaCargando,
                      onPressed: _registrar,
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
