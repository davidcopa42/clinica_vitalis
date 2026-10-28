import 'package:flutter/material.dart';

import 'package:clinica_vitalis/data/repositories/turno_repository.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';
import 'package:clinica_vitalis/ui/core/formato.dart';
import 'package:clinica_vitalis/ui/turnos/view_models/turno_view_model.dart';
import 'package:clinica_vitalis/ui/turnos/widgets/turno_confirmado.dart';

/// Pantalla para elegir especialidad, profesional, fecha y horario.
class TurnoPage extends StatefulWidget {
  const TurnoPage({
    super.key,
    required this.paciente,
  });

  final Paciente paciente;

  @override
  State<TurnoPage> createState() => _TurnoPageState();
}

class _TurnoPageState extends State<TurnoPage> {
  late final TurnoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TurnoViewModel(repositorio: TurnoRepository());
    _viewModel.cargar();
  }

  @override
  void dispose() {
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

    // Después de un await la pantalla pudo haberse cerrado.
    if (!mounted || turno == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TurnoConfirmadoPage(
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
    final vm = _viewModel;

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
            // La key cambia con el valor: así el campo se reinicia
            // cuando el ViewModel lo resetea.
            key: ValueKey('especialidad-${vm.especialidadSeleccionada}'),
            initialValue: vm.especialidadSeleccionada,
            decoration: const InputDecoration(
              labelText: 'Especialidad',
              border: OutlineInputBorder(),
            ),
            items: vm.especialidades.map((especialidad) {
              return DropdownMenuItem(
                value: especialidad,
                child: Text(especialidad),
              );
            }).toList(),
            onChanged: vm.seleccionarEspecialidad,
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            key: ValueKey(
              'profesional-${vm.especialidadSeleccionada}-'
                  '${vm.profesionalSeleccionado}',
            ),
            initialValue: vm.profesionalSeleccionado,
            decoration: const InputDecoration(
              labelText: 'Profesional',
              border: OutlineInputBorder(),
            ),
            items: vm.profesionalesDisponibles.map((profesional) {
              return DropdownMenuItem(
                value: profesional.nombre,
                child: Text(profesional.nombre),
              );
            }).toList(),
            onChanged: vm.especialidadSeleccionada == null
                ? null
                : vm.seleccionarProfesional,
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
                vm.fechaSeleccionada == null
                    ? 'Seleccionar fecha'
                    : formatearFecha(vm.fechaSeleccionada!),
              ),
            ),
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            key: ValueKey(
              'horario-${vm.profesionalSeleccionado}-'
                  '${vm.fechaSeleccionada}-${vm.horarioSeleccionado}',
            ),
            initialValue: vm.horarioSeleccionado,
            decoration: InputDecoration(
              labelText: 'Horario',
              border: const OutlineInputBorder(),
              helperText:
              vm.puedeElegirHorario && vm.horariosDisponibles.isEmpty
                  ? 'No hay horarios libres ese día.'
                  : null,
              suffixIcon: vm.cargandoHorarios
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
            items: vm.horariosDisponibles.map((horario) {
              return DropdownMenuItem(
                value: horario,
                child: Text(horario),
              );
            }).toList(),
            onChanged: vm.puedeElegirHorario ? vm.seleccionarHorario : null,
          ),

          if (vm.error != null) ...[
            const SizedBox(height: 20),
            Text(
              vm.error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],

          const SizedBox(height: 35),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: vm.guardando ? null : _confirmar,
              child: vm.guardando
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