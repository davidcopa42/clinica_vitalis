import 'package:flutter/material.dart';

import '../../core/estado_carga.dart';
import '../../core/rutas.dart';
import '../../core/widgets/vista_cargando.dart';
import '../../core/widgets/vista_error.dart';
import '../view_models/solicitar_turno_view_model.dart';
import 'datos_turno_confirmado.dart';
import 'formulario_turno.dart';

/// Pantalla para solicitar un turno nuevo.
///
/// Guarda un borrador al pasar a segundo plano y lo restaura al volver.
class SolicitarTurnoScreen extends StatefulWidget {
  const SolicitarTurnoScreen({super.key, required this.viewModel});

  final SolicitarTurnoViewModel viewModel;

  @override
  State<SolicitarTurnoScreen> createState() => _SolicitarTurnoScreenState();
}

class _SolicitarTurnoScreenState extends State<SolicitarTurnoScreen> {
  late final AppLifecycleListener _cicloDeVida;

  SolicitarTurnoViewModel get _viewModel => widget.viewModel;

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
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      firstDate: _viewModel.fechaMinima,
      lastDate: _viewModel.fechaMaxima,
      initialDate: _viewModel.fechaInicialSelector,
    );
    if (fecha != null) await _viewModel.seleccionarFecha(fecha);
  }

  Future<void> _confirmar() async {
    final paciente = _viewModel.paciente;
    final turno = await _viewModel.confirmar();
    if (!mounted || turno == null) return;

    Navigator.pushNamed(
      context,
      Rutas.turnoConfirmado,
      arguments: DatosTurnoConfirmado(paciente: paciente, turno: turno),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clínica Vitalis')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return switch (_viewModel.estado) {
            EstadoCarga.inicial ||
            EstadoCarga.cargando =>
              const VistaCargando(),
            EstadoCarga.error => VistaError(
                mensaje: 'No se pudieron cargar los profesionales.',
                onReintentar: _viewModel.cargar,
              ),
            EstadoCarga.exito => FormularioTurno(
                viewModel: _viewModel,
                onElegirFecha: _elegirFecha,
                onConfirmar: _confirmar,
              ),
          };
        },
      ),
    );
  }
}
