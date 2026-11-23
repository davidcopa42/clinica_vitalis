import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';
import '../../core/widgets/dialogo_cerrar_sesion.dart';
import '../view_models/formulario_perfil_view_model.dart';
import 'controladores_perfil.dart';
import 'formulario_perfil.dart';

/// Pantalla que pide los datos faltantes antes de usar la app.
class CompletarPerfilScreen extends StatefulWidget {
  const CompletarPerfilScreen({
    super.key,
    required this.viewModel,
    required this.onPerfilCompletado,
  });

  final FormularioPerfilViewModel viewModel;
  final VoidCallback onPerfilCompletado;

  @override
  State<CompletarPerfilScreen> createState() => _CompletarPerfilScreenState();
}

class _CompletarPerfilScreenState extends State<CompletarPerfilScreen> {
  final _claveFormulario = GlobalKey<FormState>();
  final _controladores = ControladoresPerfil();

  FormularioPerfilViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _preparar();
  }

  Future<void> _preparar() async {
    await _viewModel.prepararParaCompletar();
    if (mounted) _controladores.cargarDesde(_viewModel);
  }

  @override
  void dispose() {
    _controladores.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _viewModel.fechaInicialSelector,
      firstDate: FormularioPerfilViewModel.fechaNacimientoMinima,
      lastDate: _viewModel.fechaNacimientoMaxima,
    );
    if (fecha == null) return;
    _viewModel.seleccionarFechaNacimiento(fecha);
    _controladores.fechaNacimiento.text = _viewModel.fechaNacimientoTexto;
  }

  Future<void> _guardar() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    await _controladores.guardarEn(_viewModel);
    if (mounted && _viewModel.fueGuardado) widget.onPerfilCompletado();
  }

  Future<void> _cerrarSesion() async {
    final confirmado = await DialogoCerrarSesion.confirmar(context);
    if (confirmado) await _viewModel.cerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete su Perfil Médico'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensiones.margenPantalla),
          child: Column(
            children: [
              const Icon(
                Icons.badge,
                size: Dimensiones.iconoDestacado,
                color: Colors.blue,
              ),
              const SizedBox(height: Dimensiones.separacion),
              const Text(
                'Necesitamos algunos datos adicionales para agendar sus '
                'turnos en Clínica Vitalis.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: Dimensiones.separacionSeccion),
              FormularioPerfil(
                claveFormulario: _claveFormulario,
                controladores: _controladores,
                viewModel: _viewModel,
                textoBoton: 'Continuar a la App',
                onElegirFecha: _elegirFecha,
                onGuardar: _guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
