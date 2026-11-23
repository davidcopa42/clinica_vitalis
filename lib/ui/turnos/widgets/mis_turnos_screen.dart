import 'package:flutter/material.dart';

import '../../../domain/models/turno.dart';
import '../../core/dimensiones.dart';
import '../../core/estado_carga.dart';
import '../../core/widgets/vista_cargando.dart';
import '../../core/widgets/vista_error.dart';
import '../view_models/mis_turnos_view_model.dart';
import 'dialogo_cancelar_turno.dart';
import 'sin_turnos.dart';
import 'turno_card.dart';

/// Pantalla con los turnos confirmados y futuros del paciente.
class MisTurnosScreen extends StatefulWidget {
  const MisTurnosScreen({super.key, required this.viewModel});

  final MisTurnosViewModel viewModel;

  @override
  State<MisTurnosScreen> createState() => _MisTurnosScreenState();
}

class _MisTurnosScreenState extends State<MisTurnosScreen> {
  MisTurnosViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.cargar();
  }

  Future<void> _cancelar(Turno turno) async {
    final confirmado = await DialogoCancelarTurno.confirmar(context, turno);
    if (!confirmado) return;

    final fueCancelado = await _viewModel.cancelar(turno);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          fueCancelado
              ? 'El turno fue cancelado.'
              : _viewModel.error ?? 'No se pudo cancelar el turno.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis turnos')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return switch (_viewModel.estado) {
            EstadoCarga.inicial ||
            EstadoCarga.cargando =>
              const VistaCargando(),
            EstadoCarga.error => VistaError(
                mensaje:
                    _viewModel.error ?? 'No se pudieron cargar tus turnos.',
                onReintentar: _viewModel.cargar,
              ),
            EstadoCarga.exito when !_viewModel.tieneTurnos => const SinTurnos(),
            EstadoCarga.exito => ListView(
                padding: const EdgeInsets.all(Dimensiones.separacion),
                children: [
                  for (final turno in _viewModel.turnos)
                    TurnoCard(
                      turno: turno,
                      estaCancelando: _viewModel.estaCancelandoTurno(turno),
                      onCancelar: () => _cancelar(turno),
                    ),
                ],
              ),
          };
        },
      ),
    );
  }
}
