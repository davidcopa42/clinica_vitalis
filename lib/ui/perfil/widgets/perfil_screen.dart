import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../view_models/perfil_view_model.dart';
import 'editar_perfil_screen.dart';

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
    if (widget.viewModel.datosPerfil == null) {
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
    final fotoUrl = widget.viewModel.fotoUrl;
    final correoActual = widget.viewModel.correoActual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil Médico'),
        centerTitle: true,
        actions: [
          ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              if (widget.viewModel.estaCargando) {
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
          if (widget.viewModel.estaCargando &&
              widget.viewModel.datosPerfil == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.datosPerfil == null) {
            return const Center(child: Text('No hay datos de perfil.'));
          }

          final nombre =
              widget.viewModel.datosPerfil!['nombre'] as String? ?? '';
          final apellido =
              widget.viewModel.datosPerfil!['apellido'] as String? ?? '';
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
                        : widget.viewModel.datosPerfil!['nombre']),
                _buildInfoRow(
                    Icons.badge, 'DNI', widget.viewModel.datosPerfil!['dni']),
                _buildInfoRow(
                    Icons.calendar_today,
                    'Nacimiento',
                    _formatearFecha(
                        widget.viewModel.datosPerfil!['fechaNacimiento'])),
                _buildInfoRow(Icons.phone, 'Teléfono',
                    widget.viewModel.datosPerfil!['telefono']),
                _buildInfoRow(
                    Icons.medical_services,
                    'Obra Social',
                    _formatearObraSocial(
                        widget.viewModel.datosPerfil!['obraSocial'],
                        widget.viewModel.datosPerfil!['numeroAfiliado'])),
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
                            datosActuales: widget.viewModel.datosPerfil!,
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
