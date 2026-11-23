import 'package:flutter/material.dart';

import '../../../domain/models/paciente.dart';
import '../../core/dimensiones.dart';
import '../view_models/formulario_perfil_view_model.dart';
import 'controladores_perfil.dart';
import 'formulario_perfil.dart';

/// Pantalla para modificar los datos del perfil.
class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({
    super.key,
    required this.viewModel,
    required this.paciente,
  });

  final FormularioPerfilViewModel viewModel;
  final Paciente paciente;

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _claveFormulario = GlobalKey<FormState>();
  final _controladores = ControladoresPerfil();

  FormularioPerfilViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.prepararParaEditar(widget.paciente);
    _controladores.cargarDesde(_viewModel);
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

    if (!mounted || !_viewModel.fueGuardado) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensiones.margenPantalla),
          child: FormularioPerfil(
            claveFormulario: _claveFormulario,
            controladores: _controladores,
            viewModel: _viewModel,
            textoBoton: 'Guardar Cambios',
            onElegirFecha: _elegirFecha,
            onGuardar: _guardar,
          ),
        ),
      ),
    );
  }
}
