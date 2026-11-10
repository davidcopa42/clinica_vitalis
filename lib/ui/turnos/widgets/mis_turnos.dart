import 'package:clinica_vitalis/data/repositories/turno_repository.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';
import 'package:clinica_vitalis/ui/core/formato.dart';
import 'package:clinica_vitalis/ui/turnos/view_models/mis_turnos_view_model.dart';
import 'package:flutter/material.dart';

/// Pantalla con los turnos confirmados y futuros del paciente.
class MisTurnosPage extends StatefulWidget {
  const MisTurnosPage({
    super.key,
    required this.paciente,
  });

  final Paciente paciente;

  @override
  State<MisTurnosPage> createState() => _MisTurnosPageState();
}

class _MisTurnosPageState extends State<MisTurnosPage> {
  late final MisTurnosViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MisTurnosViewModel(
      repositorio: TurnoRepository(),
    );

    _viewModel.cargar(widget.paciente.uid);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _confirmarCancelacion(Turno turno) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar turno'),
          content: Text(
            '¿Querés cancelar tu turno de ${turno.especialidad} '
                'con ${turno.profesional}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancelar turno'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    final cancelado = await _viewModel.cancelar(turno);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cancelado
              ? 'El turno fue cancelado.'
              : _viewModel.error ?? 'No se pudo cancelar el turno.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis turnos'),
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
              return _Error(
                mensaje: _viewModel.error ?? 'No se pudieron cargar tus turnos.',
                alReintentar: () =>
                    _viewModel.cargar(widget.paciente.uid),
              );

            case EstadoCarga.exito:
              if (_viewModel.turnos.isEmpty) {
                return const _SinTurnos();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _viewModel.turnos.length,
                itemBuilder: (context, index) {
                  final turno = _viewModel.turnos[index];

                  return _TarjetaTurno(
                    turno: turno,
                    cancelando:
                    _viewModel.estaCancelando && turno.id != null,
                    onCancelar: () => _confirmarCancelacion(turno),
                  );
                },
              );
          }
        },
      ),
    );
  }
}

class _SinTurnos extends StatelessWidget {
  const _SinTurnos();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No tenés turnos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Cuando solicites un turno, aparecerá acá.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TarjetaTurno extends StatelessWidget {
  const _TarjetaTurno({
    required this.turno,
    required this.cancelando,
    required this.onCancelar,
  });

  final Turno turno;
  final bool cancelando;
  final VoidCallback onCancelar;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    turno.especialidad,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Profesional: ${turno.profesional}'),
            const SizedBox(height: 4),
            Text('Fecha: ${formatearFecha(turno.fechaHora)}'),
            Text('Horario: ${turno.horario}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: cancelando ? null : onCancelar,
                icon: cancelando
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.cancel_outlined),
                label: const Text('Cancelar turno'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({
    required this.mensaje,
    required this.alReintentar,
  });

  final String mensaje;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(mensaje),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: alReintentar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}