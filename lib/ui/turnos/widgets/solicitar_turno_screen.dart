import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';
import 'package:clinica_vitalis/ui/core/mensaje_error.dart';
import 'package:clinica_vitalis/ui/turnos/view_models/turno_view_model.dart';
import 'package:clinica_vitalis/ui/turnos/widgets/formulario_turno.dart';
import 'package:clinica_vitalis/ui/turnos/widgets/turno_confirmado_screen.dart';
import 'package:flutter/material.dart';

class SolicitarTurnoScreen extends StatefulWidget {
  const SolicitarTurnoScreen({
    super.key,
    required this.paciente,
    required this.viewModel,
  });

  final Paciente paciente;

  /// Lo crea quien abre la pantalla; la pantalla lo descarta al cerrarse.
  final TurnoViewModel viewModel;

  @override
  State<SolicitarTurnoScreen> createState() => _SolicitarTurnoScreenState();
}

class _SolicitarTurnoScreenState extends State<SolicitarTurnoScreen> {
  /// Hasta cuántos días hacia adelante se puede pedir un turno.
  static const _diasMaximosDeAnticipacion = 90;

  late final AppLifecycleListener _cicloDeVida;

  TurnoViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.cargar();

    _cicloDeVida = AppLifecycleListener(
      onHide: _viewModel.guardarBorrador,
      onResume: _viewModel.refrescar,
    );
  }

  @override
  void dispose() {
    _cicloDeVida.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: _diasMaximosDeAnticipacion)),
      initialDate: _viewModel.fechaSeleccionada ?? hoy,
    );

    if (fecha != null) {
      _viewModel.seleccionarFecha(fecha);
    }
  }

  Future<void> _confirmar() async {
    final turno = await _viewModel.confirmar(widget.paciente);

    if (!mounted || turno == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TurnoConfirmadoScreen(
          paciente: widget.paciente,
          turno: turno,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clínica Vitalis'),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          switch (_viewModel.estado) {
            case EstadoCarga.inicial:
            case EstadoCarga.cargando:
              return const Center(child: CircularProgressIndicator());
            case EstadoCarga.error:
              return MensajeError(
                mensaje: 'No se pudieron cargar los profesionales.',
                alReintentar: _viewModel.cargar,
              );
            case EstadoCarga.exito:
              return FormularioTurno(
                viewModel: _viewModel,
                alElegirFecha: _elegirFecha,
                alConfirmar: _confirmar,
              );
          }
        },
      ),
    );
  }
}
