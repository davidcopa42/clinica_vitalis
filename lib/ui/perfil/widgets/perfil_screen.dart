import 'package:flutter/material.dart';

import '../../core/dialogo_cerrar_sesion.dart';
import '../view_models/perfil_view_model.dart';
import 'editar_perfil_screen.dart';
import 'fila_dato_perfil.dart';

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
    if (widget.viewModel.paciente == null) {
      widget.viewModel.cargarPerfil(widget.uid);
    }
  }

  Future<void> _confirmarCierreSesion() async {
    final confirmar = await DialogoCerrarSesion.confirmar(context);

    if (confirmar && mounted) {
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
          final paciente = widget.viewModel.paciente;

          if (widget.viewModel.estaCargando && paciente == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (paciente == null) {
            return const Center(child: Text('No hay datos de perfil.'));
          }

          final viewModel = widget.viewModel;

          // Con scroll en pantallas bajas; en las altas el Spacer deja el
          // botón abajo de todo.
          return CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
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
                      FilaDatoPerfil(
                        icono: Icons.person,
                        etiqueta: 'Nombre Completo',
                        valor: viewModel.nombreCompletoTexto,
                      ),
                      FilaDatoPerfil(
                        icono: Icons.badge,
                        etiqueta: 'DNI',
                        valor: viewModel.dniTexto,
                      ),
                      FilaDatoPerfil(
                        icono: Icons.calendar_today,
                        etiqueta: 'Nacimiento',
                        valor: viewModel.fechaNacimientoTexto,
                      ),
                      FilaDatoPerfil(
                        icono: Icons.phone,
                        etiqueta: 'Teléfono',
                        valor: viewModel.telefonoTexto,
                      ),
                      FilaDatoPerfil(
                        icono: Icons.medical_services,
                        etiqueta: 'Obra Social',
                        valor: viewModel.obraSocialTexto,
                      ),
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
                                  paciente: paciente,
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
