import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/perfil_service.dart';
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

  final PerfilService _perfilService = PerfilService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final partesNombre = widget.nombreInicial.split(' ');
    _nombreController = TextEditingController(
        text: partesNombre.isNotEmpty ? partesNombre.first : '');
    if (partesNombre.length > 1) {
      _apellidoController.text = partesNombre.sublist(1).join(' ');
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
      setState(() => _isLoading = true);

      try {
        await _perfilService.guardarPerfil(widget.uid, {
          'nombre': _nombreController.text.trim(),
          'apellido': _apellidoController.text.trim(),
          'correo': widget.correoInicial,
          'dni': _dniController.text.trim(),
          'fechaNacimiento': _fechaSeleccionada?.toIso8601String() ?? '',
          'telefono': _telefonoController.text.trim(),
          'obraSocial': _obraSocialSeleccionada,
          'numeroAfiliado': _obraSocialSeleccionada == 'Particular'
              ? ''
              : _numeroAfiliadoController.text.trim(),
        });

        if (mounted) {
          widget.onPerfilCompletado();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar el perfil: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
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
      await AuthRepository().cerrarSesion();
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
                FormularioPerfil(
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
                  isLoading: _isLoading,
                  textoBoton: 'Continuar a la App',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
