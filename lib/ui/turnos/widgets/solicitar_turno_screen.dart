import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';
import 'package:clinica_vitalis/ui/core/formato.dart';
import 'package:clinica_vitalis/ui/turnos/view_models/turno_view_model.dart';
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
  late final AppLifecycleListener _cicloDeVida;

  TurnoViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.cargar();

    // Vinculamos los eventos del ciclo de vida a los métodos del ViewModel
    _cicloDeVida = AppLifecycleListener(
      onHide: _viewModel.guardarBorrador,
      onResume: _viewModel.refrescar,
      onStateChange: (estado) => debugPrint('Estado de la app: ${estado.name}'),
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
      lastDate: hoy.add(const Duration(days: 90)),
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
              return _Error(alReintentar: _viewModel.cargar);
            case EstadoCarga.exito:
              return _formulario();
          }
        },
      ),
    );
  }

  Widget _formulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Solicitar turno',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          DropdownButtonFormField<String>(
            key: ValueKey('especialidad-${_viewModel.especialidadSeleccionada}'),
            initialValue: _viewModel.especialidadSeleccionada,
            decoration: const InputDecoration(
              labelText: 'Especialidad',
              border: OutlineInputBorder(),
            ),
            items: _viewModel.especialidades.map((especialidad) {
              return DropdownMenuItem(
                value: especialidad,
                child: Text(especialidad),
              );
            }).toList(),
            onChanged: _viewModel.seleccionarEspecialidad,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            key: ValueKey(
              'profesional-${_viewModel.especialidadSeleccionada}-'
                  '${_viewModel.profesionalSeleccionado}',
            ),
            initialValue: _viewModel.profesionalSeleccionado,
            decoration: const InputDecoration(
              labelText: 'Profesional',
              border: OutlineInputBorder(),
            ),
            items: _viewModel.profesionalesDisponibles.map((profesional) {
              return DropdownMenuItem(
                value: profesional.nombre,
                child: Text(profesional.nombre),
              );
            }).toList(),
            onChanged: _viewModel.especialidadSeleccionada == null
                ? null
                : _viewModel.seleccionarProfesional,
          ),
          const SizedBox(height: 20),
          const Text(
            'Fecha',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _elegirFecha,
              icon: const Icon(Icons.calendar_month),
              label: Text(
                _viewModel.fechaSeleccionada == null
                    ? 'Seleccionar fecha'
                    : formatearFecha(_viewModel.fechaSeleccionada!),
              ),
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            key: ValueKey(
              'horario-${_viewModel.profesionalSeleccionado}-'
                  '${_viewModel.fechaSeleccionada}-${_viewModel.horarioSeleccionado}',
            ),
            initialValue: _viewModel.horarioSeleccionado,
            decoration: InputDecoration(
              labelText: 'Horario',
              border: const OutlineInputBorder(),
              helperText:
              _viewModel.puedeElegirHorario && _viewModel.horariosDisponibles.isEmpty
                  ? 'No hay horarios libres ese día.'
                  : null,
              suffixIcon: _viewModel.cargandoHorarios
                  ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : null,
            ),
            items: _viewModel.horariosDisponibles.map((horario) {
              return DropdownMenuItem(
                value: horario,
                child: Text(horario),
              );
            }).toList(),
            onChanged: _viewModel.puedeElegirHorario ? _viewModel.seleccionarHorario : null,
          ),
          if (_viewModel.error != null) ...[
            const SizedBox(height: 20),
            Text(
              _viewModel.error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 35),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _viewModel.guardando ? null : _confirmar,
              child: _viewModel.guardando
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Confirmar turno'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mensaje de error con botón para reintentar.
class _Error extends StatelessWidget {
  const _Error({required this.alReintentar});

  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('No se pudieron cargar los profesionales.'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: alReintentar,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}