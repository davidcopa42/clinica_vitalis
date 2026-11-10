import 'package:clinica_vitalis/ui/sintomas/view_models/sintomas_view_model.dart';
import 'package:flutter/material.dart';

/// Pantalla para registrar los síntomas del paciente.
class SintomasPage extends StatefulWidget {
  const SintomasPage({
    super.key,
    this.onSolicitarTurno,
  });

  final VoidCallback? onSolicitarTurno;

  @override
  State<SintomasPage> createState() => _SintomasPageState();
}

class _SintomasPageState extends State<SintomasPage> {
  late final SintomasViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SintomasViewModel();
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
        title: const Text('Registro de síntomas'),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 750),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registro de síntomas',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Seleccioná los síntomas que estás experimentando.',
                    ),
                    const SizedBox(height: 16),
                    _construirSeleccionSintomas(),
                    const SizedBox(height: 20),
                    const Text(
                      'Descripción adicional',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Describí cómo te sentís...',
                      ),
                      onChanged: _viewModel.cambiarDescripcion,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '¿Desde cuándo?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'Hoy',
                          label: Text('Hoy'),
                        ),
                        ButtonSegment(
                          value: '2 a 3 días',
                          label: Text('2-3 días'),
                        ),
                        ButtonSegment(
                          value: 'Más de una semana',
                          label: Text('Más de 1 semana'),
                        ),
                      ],
                      selected: {_viewModel.duracion},
                      onSelectionChanged: (seleccion) {
                        _viewModel.cambiarDuracion(seleccion.first);
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Intensidad de los síntomas',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: _viewModel.intensidad,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _viewModel.intensidad.round().toString(),
                      onChanged: _viewModel.cambiarIntensidad,
                    ),
                    Text(
                      'Intensidad: ${_viewModel.intensidad.round()} / 10',
                    ),
                    const SizedBox(height: 20),
                    if (_viewModel.tieneSignosAlarma) _construirAvisoAlarma(),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _viewModel.registrarSintomas,
                        child: const Text('Registrar síntomas'),
                      ),
                    ),
                    if (_viewModel.registrado && !_viewModel.tieneSignosAlarma)
                      _construirConfirmacion(),
                    if (_viewModel.registrado && _viewModel.tieneSignosAlarma)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'La información quedó registrada en esta sesión.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (!_viewModel.tieneSignosAlarma)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: widget.onSolicitarTurno,
                          child: const Text('Solicitar turno'),
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      'Esta herramienta no reemplaza la consulta médica '
                      'ni brinda diagnósticos.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _construirSeleccionSintomas() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _viewModel.sintomasDisponibles.map((sintoma) {
        return FilterChip(
          label: Text(sintoma),
          selected: _viewModel.sintomasSeleccionados.contains(sintoma),
          onSelected: (_) {
            _viewModel.cambiarSintoma(sintoma);
          },
        );
      }).toList(),
    );
  }

  Widget _construirAvisoAlarma() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.warning_amber,
            color: Colors.red,
            size: 40,
          ),
          SizedBox(height: 8),
          Text(
            'Acudí a la guardia ahora o llamá al 107.',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _construirConfirmacion() {
    return const Padding(
      padding: EdgeInsets.only(top: 12),
      child: Text(
        'La información quedó registrada en esta sesión. '
        'Te recomendamos solicitar un turno.',
        textAlign: TextAlign.center,
      ),
    );
  }
}
