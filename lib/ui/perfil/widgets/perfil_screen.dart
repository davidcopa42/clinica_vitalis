import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';
import '../../core/estado_carga.dart';
import '../../core/rutas.dart';
import '../../core/widgets/dialogo_cerrar_sesion.dart';
import '../../core/widgets/vista_cargando.dart';
import '../view_models/perfil_view_model.dart';
import 'datos_perfil.dart';

/// Pantalla con los datos del perfil del paciente.
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key, required this.viewModel});

  final PerfilViewModel viewModel;

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  PerfilViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.cargar();
  }

  Future<void> _editar() async {
    await Navigator.pushNamed(
      context,
      Rutas.editarPerfil,
      arguments: _viewModel.paciente,
    );
    await _viewModel.cargar();
  }

  Future<void> _cerrarSesion() async {
    final confirmado = await DialogoCerrarSesion.confirmar(context);
    if (!confirmado) return;
    await _viewModel.cerrarSesion();
    if (mounted) Navigator.of(context).popUntil((ruta) => ruta.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil Médico'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.paciente == null) {
            return _viewModel.estado == EstadoCarga.cargando
                ? const VistaCargando()
                : const Center(child: Text('No hay datos de perfil.'));
          }
          return ListView(
            padding: const EdgeInsets.all(Dimensiones.margenPantalla),
            children: [
              DatosPerfil(viewModel: _viewModel),
              const SizedBox(height: Dimensiones.separacionExtra),
              SizedBox(
                height: Dimensiones.altoBoton,
                child: ElevatedButton.icon(
                  onPressed: _editar,
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Información'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
