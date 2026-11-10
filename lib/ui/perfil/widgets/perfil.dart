import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../view_models/perfil_view_model.dart';
import 'formulario_perfil.dart';

class PerfilScreen extends StatefulWidget {
  final String uid;
  final PerfilViewModel viewModel;

  const PerfilScreen({super.key, required this.uid, required this.viewModel});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.viewModel.perfilData == null) {
      widget.viewModel.cargarPerfil(widget.uid);
    }
  }

  String _formatearFecha(String? fechaStr) {
    if (fechaStr == null || fechaStr.isEmpty) {
      return 'No registrado';
    }
    try {
      final dt = DateTime.parse(fechaStr);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return fechaStr;
    }
  }

  String _formatearObraSocial(String? obraSocial, String? numeroAfiliado) {
    if (obraSocial == null || obraSocial.isEmpty) {
      return 'No registrado';
    }
    if (obraSocial != 'Particular' &&
        numeroAfiliado != null &&
        numeroAfiliado.isNotEmpty) {
      return '$obraSocial (Nº $numeroAfiliado)';
    }
    return obraSocial;
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
      await widget.viewModel.cerrarSesion();

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userActual = FirebaseAuth.instance.currentUser;
    final fotoUrl = userActual?.photoURL;
    final correoActual = userActual?.email ?? 'Sin correo electrónico';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil Médico'),
        centerTitle: true,
        actions: [
          ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              if (widget.viewModel.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.blueAccent),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Cerrar sesión',
            onPressed: _confirmarCierreSesion,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading &&
              widget.viewModel.perfilData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.perfilData == null) {
            return const Center(child: Text('No hay datos de perfil.'));
          }

          final nombre =
              widget.viewModel.perfilData!['nombre'] as String? ?? '';
          final apellido =
              widget.viewModel.perfilData!['apellido'] as String? ?? '';
          final nombreCompleto = '$nombre $apellido'.trim();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage:
                            fotoUrl != null ? NetworkImage(fotoUrl) : null,
                        child: fotoUrl == null
                            ? const Icon(Icons.person,
                                size: 50, color: Colors.blue)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        correoActual,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildInfoRow(
                    Icons.person,
                    'Nombre Completo',
                    nombreCompleto.isNotEmpty
                        ? nombreCompleto
                        : widget.viewModel.perfilData!['nombre']),
                _buildInfoRow(
                    Icons.badge, 'DNI', widget.viewModel.perfilData!['dni']),
                _buildInfoRow(
                    Icons.calendar_today,
                    'Nacimiento',
                    _formatearFecha(
                        widget.viewModel.perfilData!['fechaNacimiento'])),
                _buildInfoRow(Icons.phone, 'Teléfono',
                    widget.viewModel.perfilData!['telefono']),
                _buildInfoRow(
                    Icons.medical_services,
                    'Obra Social',
                    _formatearObraSocial(
                        widget.viewModel.perfilData!['obraSocial'],
                        widget.viewModel.perfilData!['numeroAfiliado'])),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditarPerfilScreen(
                            uid: widget.uid,
                            datosActuales: widget.viewModel.perfilData!,
                            viewModel: widget.viewModel,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar Información',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    final displayValue =
        (value == null || value.isEmpty) ? 'No registrado' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              Text(displayValue,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

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
  bool _isLoading = false;

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
        widget.datosActuales['obraSocial'] ?? 'Particular';
    const obrasValidas = [
      'Particular',
      'OSDE',
      'Swiss Medical',
      'Galeno',
      'PAMI',
      'IOMA',
      'Otra'
    ];
    if (!obrasValidas.contains(_obraSocialSeleccionada)) {
      _obraSocialSeleccionada = 'Particular';
    }

    final fechaStr = widget.datosActuales['fechaNacimiento'] as String?;
    _fechaNacimientoController = TextEditingController();
    if (fechaStr != null && fechaStr.isNotEmpty) {
      try {
        _fechaSeleccionada = DateTime.parse(fechaStr);
        _fechaNacimientoController.text =
            DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!);
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
          DateTime.now().subtract(const Duration(days: 365 * 18)),
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

  void _guardarCambios(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

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
            'numeroAfiliado': _obraSocialSeleccionada == 'Particular'
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
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar el perfil: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
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
              isLoading: _isLoading,
              textoBoton: 'Guardar Cambios',
            ),
          ),
        ),
      ),
    );
  }
}
