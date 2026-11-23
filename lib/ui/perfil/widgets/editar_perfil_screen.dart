import 'package:flutter/material.dart';

import '../../../domain/models/obra_social.dart';
import '../../core/formato.dart';
import '../view_models/perfil_view_model.dart';
import 'formulario_perfil.dart';
import 'limites_fecha_nacimiento.dart';

class EditarPerfilScreen extends StatefulWidget {
  final String uid;
  final Map<String, dynamic> datosActuales;
  final PerfilViewModel viewModel;

  const EditarPerfilScreen(
      {super.key,
      required this.uid,
      required this.datosActuales,
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
    _nombreController =
        TextEditingController(text: widget.datosActuales['nombre'] ?? '');
    _apellidoController =
        TextEditingController(text: widget.datosActuales['apellido'] ?? '');
    _dniController =
        TextEditingController(text: widget.datosActuales['dni'] ?? '');
    _telefonoController =
        TextEditingController(text: widget.datosActuales['telefono'] ?? '');
    _numeroAfiliadoController = TextEditingController(
        text: widget.datosActuales['numeroAfiliado'] ?? '');

    _obraSocialSeleccionada =
        widget.datosActuales['obraSocial'] ?? obraSocialParticular;
    if (!obrasSocialesDisponibles.contains(_obraSocialSeleccionada)) {
      _obraSocialSeleccionada = obraSocialParticular;
    }

    final fechaStr = widget.datosActuales['fechaNacimiento'] as String?;
    _fechaNacimientoController = TextEditingController();
    if (fechaStr != null && fechaStr.isNotEmpty) {
      try {
        _fechaSeleccionada = DateTime.parse(fechaStr);
        _fechaNacimientoController.text =
            formatearFecha(_fechaSeleccionada!);
      } catch (_) {
        _fechaNacimientoController.text = fechaStr;
      }
    }
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
          {
            'nombre': _nombreController.text.trim(),
            'apellido': _apellidoController.text.trim(),
            'dni': _dniController.text.trim(),
            'fechaNacimiento': _fechaSeleccionada?.toIso8601String() ??
                widget.datosActuales['fechaNacimiento'] ??
                '',
            'telefono': _telefonoController.text.trim(),
            'obraSocial': _obraSocialSeleccionada,
            'numeroAfiliado': _obraSocialSeleccionada == obraSocialParticular
                ? ''
                : _numeroAfiliadoController.text.trim(),
          },
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
