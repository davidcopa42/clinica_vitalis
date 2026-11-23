import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';
import '../../core/widgets/boton_principal.dart';
import '../view_models/solicitar_turno_view_model.dart';

/// Campos para elegir especialidad, profesional, fecha y horario.
class FormularioTurno extends StatelessWidget {
  const FormularioTurno({
    super.key,
    required this.viewModel,
    required this.onElegirFecha,
    required this.onConfirmar,
  });

  final SolicitarTurnoViewModel viewModel;
  final VoidCallback onElegirFecha;
  final VoidCallback onConfirmar;

  @override
  Widget build(BuildContext context) {
    final error = viewModel.error;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensiones.margenContenido),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Solicitar turno',
            style: TextStyle(
              fontSize: Dimensiones.textoTitulo,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Dimensiones.separacionExtra),
          _SelectorOpcion(
            clave: 'especialidad-${viewModel.especialidadSeleccionada}',
            etiqueta: 'Especialidad',
            valor: viewModel.especialidadSeleccionada,
            opciones: viewModel.especialidades,
            onChanged: viewModel.seleccionarEspecialidad,
          ),
          const SizedBox(height: Dimensiones.separacionGrande),
          _SelectorOpcion(
            clave: 'profesional-${viewModel.especialidadSeleccionada}-'
                '${viewModel.profesionalSeleccionado}',
            etiqueta: 'Profesional',
            valor: viewModel.profesionalSeleccionado,
            opciones: viewModel.profesionalesDisponibles,
            onChanged: viewModel.puedeElegirProfesional
                ? viewModel.seleccionarProfesional
                : null,
          ),
          const SizedBox(height: Dimensiones.separacionGrande),
          const Text('Fecha'),
          const SizedBox(height: Dimensiones.separacionChica),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onElegirFecha,
              icon: const Icon(Icons.calendar_month),
              label: Text(viewModel.fechaTexto),
            ),
          ),
          const SizedBox(height: Dimensiones.separacionGrande),
          _SelectorOpcion(
            clave: 'horario-${viewModel.profesionalSeleccionado}-'
                '${viewModel.fechaSeleccionada}-'
                '${viewModel.horarioSeleccionado}',
            etiqueta: 'Horario',
            valor: viewModel.horarioSeleccionado,
            opciones: viewModel.horariosDisponibles,
            ayuda: viewModel.ayudaHorario,
            estaCargando: viewModel.estaCargandoHorarios,
            onChanged: viewModel.puedeElegirHorario
                ? viewModel.seleccionarHorario
                : null,
          ),
          if (error != null) ...[
            const SizedBox(height: Dimensiones.separacionGrande),
            Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: Dimensiones.separacionSeccion),
          BotonPrincipal(
            texto: 'Confirmar turno',
            estaCargando: viewModel.estaGuardando,
            onPressed: onConfirmar,
          ),
        ],
      ),
    );
  }
}

/// Lista desplegable de textos con etiqueta, ayuda y spinner opcionales.
class _SelectorOpcion extends StatelessWidget {
  const _SelectorOpcion({
    required this.clave,
    required this.etiqueta,
    required this.valor,
    required this.opciones,
    required this.onChanged,
    this.ayuda,
    this.estaCargando = false,
  });

  /// Fuerza a reconstruir el campo cuando cambia su valor desde el ViewModel.
  final String clave;
  final String etiqueta;
  final String? valor;
  final List<String> opciones;
  final ValueChanged<String?>? onChanged;
  final String? ayuda;
  final bool estaCargando;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey(clave),
      initialValue: valor,
      decoration: InputDecoration(
        labelText: etiqueta,
        border: const OutlineInputBorder(),
        helperText: ayuda,
        suffixIcon: estaCargando
            ? const Padding(
                padding: EdgeInsets.all(Dimensiones.separacionMedia),
                child: SizedBox.square(
                  dimension: Dimensiones.separacion,
                  child: CircularProgressIndicator(
                    strokeWidth: Dimensiones.grosorSpinner,
                  ),
                ),
              )
            : null,
      ),
      items: [
        for (final opcion in opciones)
          DropdownMenuItem(value: opcion, child: Text(opcion)),
      ],
      onChanged: onChanged,
    );
  }
}
