import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';
import 'package:clinica_vitalis/ui/core/mensaje_error.dart';
import 'package:clinica_vitalis/ui/historia_clinica/view_models/historia_clinica_view_model.dart';
import 'package:clinica_vitalis/ui/historia_clinica/widgets/lista_registros.dart';
import 'package:flutter/material.dart';

/// Pantalla que muestra la historia clínica del paciente.
class HistoriaClinicaScreen extends StatefulWidget {
  const HistoriaClinicaScreen({
    super.key,
    required this.paciente,
    required this.viewModel,
  });

  final Paciente paciente;

  /// Lo crea quien abre la pantalla; la pantalla lo descarta al cerrarse.
  final HistoriaClinicaViewModel viewModel;

  @override
  State<HistoriaClinicaScreen> createState() => _HistoriaClinicaScreenState();
}

class _HistoriaClinicaScreenState extends State<HistoriaClinicaScreen> {
  HistoriaClinicaViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel.cargar(widget.paciente.uid);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historia clínica'),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          switch (_viewModel.estado) {
            case EstadoCarga.inicial:
            case EstadoCarga.cargando:
              return const Center(
                child: CircularProgressIndicator(),
              );

            case EstadoCarga.error:
              return MensajeError(
                mensaje: _viewModel.mensajeError ?? 'Ocurrió un error.',
                alReintentar: _viewModel.reintentar,
              );

            case EstadoCarga.exito:
              return ListaRegistros(
                registros: _viewModel.registrosFiltrados,
                filtro: _viewModel.filtro,
                alCambiarFiltro: _viewModel.cambiarFiltro,
              );
          }
        },
      ),
    );
  }
}
