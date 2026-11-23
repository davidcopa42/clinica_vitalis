import 'package:flutter/material.dart';

import '../../../domain/models/obra_social.dart';
import '../../core/dialogo_cerrar_sesion.dart';
import '../../core/formato.dart';
import '../view_models/completar_perfil_view_model.dart';
import 'formulario_perfil.dart';
import 'limites_fecha_nacimiento.dart';

class CompletarPerfilScreen extends StatefulWidget {
  /// Lo crea y lo descarta PuertaSesion.
  final CompletarPerfilViewModel viewModel;
  final String uid;
  final String correoInicial;
  final String nombreInicial;
  final VoidCallback onPerfilCompletado;

  const CompletarPerfilScreen({
    super.key,
    required this.viewModel,
    required this.uid,
    required this.correoInicial,
    required this.nombreInicial,
    required this.onPerfilCompletado,
  });

  @override
  State<CompletarPerfilScreen> createState() => _CompletarPerfilScreenState();
}

class _CompletarPerfilScreenState extends State<CompletarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  final _apellidoController = TextEditingController();
  final _dniController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _numeroAfiliadoController = TextEditingController();

  String _obraSocialSeleccionada = obraSocialParticular;
  DateTime? _fechaSeleccionada;

  CompletarPerfilViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    final nombreSeparado =
        _viewModel.separarNombreInicial(widget.nombreInicial);
    _nombreController = TextEditingController(text: nombreSeparado.nombre);
    _apellidoController.text = nombreSeparado.apellido;
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
      initialDate: DateTime.now().subtract(antiguedadSugeridaNacimiento),
      firstDate: primeraFechaNacimiento,
      lastDate: DateTime.now(),
    );

    if (seleccion != null && seleccion != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = seleccion;
        _fechaNacimientoController.text = formatearFecha(seleccion);
      });
    }
  }

  void _guardarPerfil() async {
    if (_formKey.currentState?.validate() ?? false) {
      final error = await _viewModel.guardarPerfil(
        uid: widget.uid,
        nombre: _nombreController.text,
        apellido: _apellidoController.text,
        correo: widget.correoInicial,
        dni: _dniController.text,
        fechaNacimiento: _fechaSeleccionada,
        telefono: _telefonoController.text,
        obraSocial: _obraSocialSeleccionada,
        numeroAfiliado: _numeroAfiliadoController.text,
      );
      if (!mounted) return;

      if (error == null) {
        widget.onPerfilCompletado();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  Future<void> _confirmarCierreSesion() async {
    final confirmar = await DialogoCerrarSesion.confirmar(context);

    if (confirmar && mounted) {
      await _viewModel.cerrarSesion();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
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
            onPressed: _confirmarCierreSesion,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.badge, size: 70, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'Necesitamos algunos datos adicionales para agendar sus turnos en Clínica Vitalis.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, _) {
                    return FormularioPerfil(
                      formKey: _formKey,
                      nombreController: _nombreController,
                      apellidoController: _apellidoController,
                      dniController: _dniController,
                      fechaNacimientoController: _fechaNacimientoController,
                      telefonoController: _telefonoController,
                      obraSocialValue: _obraSocialSeleccionada,
                      numeroAfiliadoController: _numeroAfiliadoController,
                      onObraSocialChanged: (nuevoValor) {
                        if (nuevoValor != null) {
                          setState(() => _obraSocialSeleccionada = nuevoValor);
                        }
                      },
                      onTapFecha: () => _seleccionarFecha(context),
                      onGuardar: _guardarPerfil,
                      estaGuardando: _viewModel.estaGuardando,
                      textoBoton: 'Continuar a la App',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
