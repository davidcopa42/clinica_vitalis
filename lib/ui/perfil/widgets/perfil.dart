import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../providers/perfil_provider.dart';
import 'formulario_perfil.dart';
import '../../../data/repositories/auth_repository.dart';

class PerfilScreen extends StatefulWidget {
  final String uid;

  const PerfilScreen({super.key, required this.uid});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PerfilProvider>().cargarPerfil(widget.uid);
    });
  }

  String _formatearFecha(String? fechaStr) {
    if (fechaStr == null || fechaStr.isEmpty) return 'No registrado';
    try {
      final dt = DateTime.parse(fechaStr);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return fechaStr;
    }
  }

  String _formatearObraSocial(String? obraSocial, String? numeroAfiliado) {
    if (obraSocial == null || obraSocial.isEmpty) return 'No registrado';
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
      await AuthRepository().cerrarSesion();

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PerfilProvider>();

    final userActual = FirebaseAuth.instance.currentUser;
    final fotoUrl = userActual?.photoURL;
    final correoActual = userActual?.email ?? 'Sin correo electrónico';

    final nombre = provider.perfilData?['nombre'] as String? ?? '';
    final apellido = provider.perfilData?['apellido'] as String? ?? '';
    final nombreCompleto = '$nombre $apellido'.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil Médico'),
        centerTitle: true,
        actions: [
          // Indicador sutil de sincronización en segundo plano sin bloquear la pantalla
          if (provider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.blueAccent),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Cerrar sesión',
            onPressed: _confirmarCierreSesion,
          ),
        ],
      ),
      body: (provider.isLoading && provider.perfilData == null)
          ? const Center(
              child:
                  CircularProgressIndicator()) // Solo aparece la primera vez que no hay datos
          : provider.perfilData == null
              ? const Center(child: Text('No hay datos de perfil.'))
              : Padding(
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
                              backgroundImage: fotoUrl != null
                                  ? NetworkImage(fotoUrl)
                                  : null,
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
                              : provider.perfilData!['nombre']),
                      _buildInfoRow(
                          Icons.badge, 'DNI', provider.perfilData!['dni']),
                      _buildInfoRow(
                          Icons.calendar_today,
                          'Nacimiento',
                          _formatearFecha(
                              provider.perfilData!['fechaNacimiento'])),
                      _buildInfoRow(Icons.phone, 'Teléfono',
                          provider.perfilData!['telefono']),
                      _buildInfoRow(
                          Icons.medical_services,
                          'Obra Social',
                          _formatearObraSocial(
                              provider.perfilData!['obraSocial'],
                              provider.perfilData!['numeroAfiliado'])),
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
                                  datosActuales: provider.perfilData!,
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

  const EditarPerfilScreen(
      {super.key, required this.uid, required this.datosActuales});

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
        await context.read<PerfilProvider>().actualizarPerfil(
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
