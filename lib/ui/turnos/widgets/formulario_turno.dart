import 'package:flutter/material.dart';

import '../view_models/turno_view_model.dart';

/// Formulario para elegir especialidad, profesional, fecha y horario.
///
/// Recibe el ViewModel porque muestra casi todo su estado; la elección de
/// fecha y la confirmación las resuelve la pantalla.
///
/// En celulares muestra los campos en una columna; desde
/// [anchoDosColumnas] (tablets), en dos.
class FormularioTurno extends StatelessWidget {
  const FormularioTurno({
    super.key,
    required this.viewModel,
    required this.alElegirFecha,
    required this.alConfirmar,
  });

  /// A partir de este ancho el formulario se muestra en dos columnas.
  static const anchoDosColumnas = 600.0;

  /// Ancho máximo, para que en pantallas muy anchas los campos no queden
  /// estirados de punta a punta.
  static const anchoMaximo = 900.0;

  final TurnoViewModel viewModel;
  final VoidCallback alElegirFecha;
  final VoidCallback alConfirmar;

  @override
  Widget build(BuildContext context) {
    final especialidad = _CampoEspecialidad(viewModel: viewModel);
    final profesional = _CampoProfesional(viewModel: viewModel);
    final fecha = _CampoFecha(viewModel: viewModel, alElegir: alElegirFecha);
    final horario = _CampoHorario(viewModel: viewModel);

    return LayoutBuilder(
      builder: (context, restricciones) {
        final dosColumnas = restricciones.maxWidth > anchoDosColumnas;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: anchoMaximo),
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
                  if (dosColumnas)
                    _DosColumnas(
                      izquierda: [especialidad, profesional],
                      derecha: [fecha, horario],
                    )
                  else
                    _Campos([especialidad, profesional, fecha, horario]),
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
                  _BotonConfirmar(
                      viewModel: viewModel, alConfirmar: alConfirmar),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Tablet: a la izquierda "con quién" y a la derecha "cuándo".
class _DosColumnas extends StatelessWidget {
  const _DosColumnas({required this.izquierda, required this.derecha});

  final List<Widget> izquierda;
  final List<Widget> derecha;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TituloSeccion('¿Con quién?'),
              _Campos(izquierda),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TituloSeccion('¿Cuándo?'),
              _Campos(derecha),
            ],
          ),
        ),
      ],
    );
  }
}

/// Campos uno debajo del otro, separados por el mismo espacio.
class _Campos extends StatelessWidget {
  const _Campos(this.campos);

  static const _separacion = 20.0;

  final List<Widget> campos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (indice, campo) in campos.indexed) ...[
          if (indice > 0) const SizedBox(height: _separacion),
          campo,
        ],
      ],
    );
  }
}

/// Título chico arriba de cada columna en el diseño de tablet.
class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _CampoEspecialidad extends StatelessWidget {
  const _CampoEspecialidad({required this.viewModel});

  final TurnoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
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
    );
  }
}

class _CampoProfesional extends StatelessWidget {
  const _CampoProfesional({required this.viewModel});

  final TurnoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
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
    );
  }
}

class _CampoFecha extends StatelessWidget {
  const _CampoFecha({required this.viewModel, required this.alElegir});

  final TurnoViewModel viewModel;
  final VoidCallback alElegir;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: alElegir,
            icon: const Icon(Icons.calendar_month),
            label: Text(viewModel.fechaTexto),
          ),
        ),
      ],
    );
  }
}

class _CampoHorario extends StatelessWidget {
  const _CampoHorario({required this.viewModel});

  final TurnoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
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
      onChanged:
          viewModel.puedeElegirHorario ? viewModel.seleccionarHorario : null,
    );
  }
}

class _BotonConfirmar extends StatelessWidget {
  const _BotonConfirmar({required this.viewModel, required this.alConfirmar});

  final TurnoViewModel viewModel;
  final VoidCallback alConfirmar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}
