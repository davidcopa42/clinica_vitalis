import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';
import '../../core/estado_carga.dart';
import '../../core/rutas.dart';
import '../../core/widgets/vista_cargando.dart';
import '../../core/widgets/vista_error.dart';
import '../view_models/historia_clinica_view_model.dart';
import 'filtro_registros.dart';
import 'registro_clinico_card.dart';

/// Pantalla que muestra la historia clinica del paciente.
class HistoriaClinicaScreen extends StatefulWidget {
  const HistoriaClinicaScreen({super.key, required this.viewModel});

  final HistoriaClinicaViewModel viewModel;

  @override
  State<HistoriaClinicaScreen> createState() => _HistoriaClinicaScreenState();
}

class _HistoriaClinicaScreenState extends State<HistoriaClinicaScreen> {
  HistoriaClinicaViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historia clínica')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return switch (_viewModel.estado) {
            EstadoCarga.inicial ||
            EstadoCarga.cargando =>
              const VistaCargando(),
            EstadoCarga.error => VistaError(
                mensaje: _viewModel.mensajeError ?? 'Ocurrió un error.',
                onReintentar: _viewModel.cargar,
              ),
            EstadoCarga.exito => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(Dimensiones.separacionMedia),
                    child: FiltroRegistros(
                      seleccionado: _viewModel.filtro,
                      onCambiar: _viewModel.cambiarFiltro,
                    ),
                  ),
                  Expanded(
                    child: _viewModel.hayRegistrosFiltrados
                        ? ListView(
                            children: [
                              for (final registro
                                  in _viewModel.registrosFiltrados)
                                RegistroClinicoCard(
                                  registro: registro,
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    Rutas.detalleRegistro,
                                    arguments: registro,
                                  ),
                                ),
                            ],
                          )
                        : const Center(
                            child: Text('No hay registros para este filtro.'),
                          ),
                  ),
                ],
              ),
          };
        },
      ),
    );
  }
}
