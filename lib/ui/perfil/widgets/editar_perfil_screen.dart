import 'package:flutter/material.dart';

import '../../../domain/models/obra_social.dart';
import '../../../domain/models/paciente.dart';
import '../../core/formato.dart';
import '../view_models/perfil_view_model.dart';
import 'formulario_perfil.dart';
import 'limites_fecha_nacimiento.dart';

class EditarPerfilScreen extends StatefulWidget {
  final String uid;

  /// Perfil tal como está antes de editarlo.
  final Paciente paciente;
  final PerfilViewModel viewModel;

  const EditarPerfilScreen(
      {super.key,
      required this.uid,
      required this.paciente,
      required this.viewModel});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidoController;
  late final TextEditingController _dniController;
  late final TextEditingController _fechaNacimientoController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _numeroAfiliadoController;

  late String _obraSocialSeleccionada;
  DateTime? _fechaSeleccionada;
  bool _estaGuardando = false;

  @override
  void initState() {
    super.initState();
    final paciente = widget.paciente;
    _nombreController = TextEditingController(text: paciente.nombre);
    _apellidoController = TextEditingController(text: paciente.apellido);
    _dniController = TextEditingController(text: paciente.dni);
    _telefonoController = TextEditingController(text: paciente.telefono);
    _numeroAfiliadoController =
        TextEditingController(text: paciente.numeroAfiliado ?? '');

    final obraSocial = paciente.obraSocial ?? obraSocialParticular;
    _obraSocialSeleccionada = obrasSocialesDisponibles.contains(obraSocial)
        ? obraSocial
        : obraSocialParticular;

    _fechaSeleccionada = paciente.fechaNacimiento;
    final fecha = _fechaSeleccionada;
    _fechaNacimientoController =
        TextEditingController(text: fecha == null ? '' : formatearFecha(fecha));
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _dniController.dispose();
    _fechaNacimientoController.dispose();
    _telefonoController.dispose();
    _numeroAfiliadoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? seleccion = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ??
          DateTime.now().subtract(antiguedadSugeridaNacimiento),
      firstDate: primeraFechaNacimiento,
      lastDate: DateTime.now(),
    );

    if (seleccion != null && seleccion != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = seleccion;
        _fechaNacimientoController.text =
            formatearFecha(seleccion);
      });
    }
  }

  void _guardarCambios(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _estaGuardando = true);

      try {
        await widget.viewModel.actualizarPerfil(
          widget.uid,
          widget.paciente.copyWith(
            nombre: _nombreController.text.trim(),
            apellido: _apellidoController.text.trim(),
            dni: _dniController.text.trim(),
            // Si no se eligió otra fecha, copyWith conserva la anterior.
            fechaNacimiento: _fechaSeleccionada,
            telefono: _telefonoController.text.trim(),
            obraSocial: _obraSocialSeleccionada,
            numeroAfiliado: _obraSocialSeleccionada == obraSocialParticular
                ? ''
                : _numeroAfiliadoController.text.trim(),
          ),
        );

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado correctamente')),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar el perfil: $error')),
          );
        }
      } finally {
        if (mounted) setState(() => _estaGuardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: FormularioPerfil(
              formKey: _formKey,
              nombreController: _nombreController,
              apellidoController: _apellidoController,
              dniController: _dniController,
              fechaNacimientoController: _fechaNacimientoController,
              telefonoController: _telefonoController,
              obraSocialValue: _obraSocialSeleccionada,
              onObraSocialChanged: (nuevoValor) {
                if (nuevoValor != null) {
                  setState(() => _obraSocialSeleccionada = nuevoValor);
                }
              },
              numeroAfiliadoController: _numeroAfiliadoController,
              onTapFecha: () => _seleccionarFecha(context),
              onGuardar: () => _guardarCambios(context),
              estaGuardando: _estaGuardando,
              textoBoton: 'Guardar Cambios',
            ),
          ),
        ),
      ),
    );
  }
}
