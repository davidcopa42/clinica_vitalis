import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/auth_repositorio_firebase.dart';
import '../../../data/repositories/perfil_repositorio_firestore.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/perfil_service.dart';
import '../view_models/completar_perfil_view_model.dart';
import 'formulario_perfil.dart';

class CompletarPerfilScreen extends StatefulWidget {
  final String uid;
  final String correoInicial;
  final String nombreInicial;
  final VoidCallback onPerfilCompletado;

  const CompletarPerfilScreen({
    super.key,
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

  String _obraSocialSeleccionada = 'Particular';
  DateTime? _fechaSeleccionada;

  late final CompletarPerfilViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CompletarPerfilViewModel(
      perfilRepository:
          PerfilRepositorioFirestore(perfilService: PerfilService()),
      authRepository: AuthRepositorioFirebase(authService: AuthService()),
    );
    final nombreSeparado =
        _viewModel.separarNombreInicial(widget.nombreInicial);
    _nombreController = TextEditingController(text: nombreSeparado.nombre);
    _apellidoController.text = nombreSeparado.apellido;
  }

  @override
  void dispose() {
    _viewModel.dispose();
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
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (seleccion != null && seleccion != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = seleccion;
        _fechaNacimientoController.text =
            DateFormat('dd/MM/yyyy').format(seleccion);
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
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
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
                      isLoading: _viewModel.estaGuardando,
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
