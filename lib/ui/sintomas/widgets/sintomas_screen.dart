import 'package:flutter/material.dart';

import '../view_models/sintomas_view_model.dart';
import 'aviso_alarma.dart';
import 'recomendacion_turno.dart';
import 'seleccion_sintomas.dart';

/// Pantalla para registrar los síntomas del paciente.
class SintomasScreen extends StatefulWidget {
  const SintomasScreen({
    super.key,
    required this.viewModel,
    this.onSolicitarTurno,
  });

  final VoidCallback? onSolicitarTurno;

  /// Lo crea quien abre la pantalla; la pantalla lo descarta al cerrarse.
  final SintomasViewModel viewModel;

  @override
  State<SintomasScreen> createState() => _SintomasScreenState();
}

class _SintomasScreenState extends State<SintomasScreen> {
  SintomasViewModel get _viewModel => widget.viewModel;
  late final AppLifecycleListener _cicloDeVida;
  late final TextEditingController _descripcionController;

  @override
  void initState() {
    super.initState();
    _descripcionController = TextEditingController();

    _viewModel.addListener(_sincronizarControlador);

    _cicloDeVida = AppLifecycleListener(
      onHide: _viewModel.guardarBorrador,
      onResume: _viewModel.refrescar,
    );
  }

  void _sincronizarControlador() {
    if (_descripcionController.text != _viewModel.descripcion) {
      _descripcionController.text = _viewModel.descripcion;
      _descripcionController.selection = TextSelection.fromPosition(
        TextPosition(offset: _descripcionController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_sincronizarControlador);
    _cicloDeVida.dispose();
    _viewModel.dispose();
    _descripcionController.dispose();
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
                    SeleccionSintomas(
                      disponibles: _viewModel.sintomasDisponibles,
                      seleccionados: _viewModel.sintomasSeleccionados,
                      alCambiar: _viewModel.cambiarSintoma,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Descripción adicional',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descripcionController,
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
                      label: _viewModel.intensidadEtiqueta,
                      onChanged: _viewModel.cambiarIntensidad,
                    ),
                    Text(_viewModel.intensidadTexto),
                    const SizedBox(height: 20),
                    if (_viewModel.tieneSignosAlarma) const AvisoAlarma(),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _viewModel.registrarSintomas,
                        child: const Text('Registrar síntomas'),
                      ),
                    ),
                    if (_viewModel.mostrarRecomendacionDeTurno)
                      const RecomendacionTurno(),
                    if (_viewModel.mostrarRegistroConAlarma)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'La información quedó registrada en esta sesión.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (_viewModel.puedeSolicitarTurno)
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
}
