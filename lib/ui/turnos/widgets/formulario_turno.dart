import 'package:flutter/material.dart';

import '../view_models/turno_view_model.dart';

/// Formulario para elegir especialidad, profesional, fecha y horario.
///
/// Recibe el ViewModel porque muestra casi todo su estado; la elección de
/// fecha y la confirmación las resuelve la pantalla.
class FormularioTurno extends StatelessWidget {
  const FormularioTurno({
    super.key,
    required this.viewModel,
    required this.alElegirFecha,
    required this.alConfirmar,
  });

  final TurnoViewModel viewModel;
  final VoidCallback alElegirFecha;
  final VoidCallback alConfirmar;

  @override
  Widget build(BuildContext context) {
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
            key: ValueKey('especialidad-${viewModel.especialidadSeleccionada}'),
            initialValue: viewModel.especialidadSeleccionada,
            decoration: const InputDecoration(
              labelText: 'Especialidad',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final especialidad in viewModel.especialidades)
                DropdownMenuItem(
                  value: especialidad,
                  child: Text(especialidad),
                ),
            ],
            onChanged: viewModel.seleccionarEspecialidad,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            key: ValueKey(
              'profesional-${viewModel.especialidadSeleccionada}-'
              '${viewModel.profesionalSeleccionado}',
            ),
            initialValue: viewModel.profesionalSeleccionado,
            decoration: const InputDecoration(
              labelText: 'Profesional',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final profesional in viewModel.profesionalesDisponibles)
                DropdownMenuItem(
                  value: profesional.nombre,
                  child: Text(profesional.nombre),
                ),
            ],
            onChanged: viewModel.puedeElegirProfesional
                ? viewModel.seleccionarProfesional
                : null,
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
              onPressed: alElegirFecha,
              icon: const Icon(Icons.calendar_month),
              label: Text(viewModel.fechaTexto),
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            key: ValueKey(
              'horario-${viewModel.profesionalSeleccionado}-'
              '${viewModel.fechaSeleccionada}-${viewModel.horarioSeleccionado}',
            ),
            initialValue: viewModel.horarioSeleccionado,
            decoration: InputDecoration(
              labelText: 'Horario',
              border: const OutlineInputBorder(),
              helperText: viewModel.avisoSinHorarios,
              suffixIcon: viewModel.cargandoHorarios
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
            items: [
              for (final horario in viewModel.horariosDisponibles)
                DropdownMenuItem(
                  value: horario,
                  child: Text(horario),
                ),
            ],
            onChanged: viewModel.puedeElegirHorario
                ? viewModel.seleccionarHorario
                : null,
          ),
          if (viewModel.error != null) ...[
            const SizedBox(height: 20),
            Text(
              viewModel.error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 35),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: viewModel.guardando ? null : alConfirmar,
              child: viewModel.guardando
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
