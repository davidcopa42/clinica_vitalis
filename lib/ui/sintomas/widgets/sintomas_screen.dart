import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';
import '../../core/rutas.dart';
import '../view_models/duracion_sintomas.dart';
import '../view_models/sintomas_view_model.dart';
import 'aviso_alarma.dart';
import 'confirmacion_sintomas.dart';
import 'seleccion_sintomas.dart';

/// Pantalla para registrar los sintomas del paciente.
///
/// Guarda un borrador al pasar a segundo plano y lo restaura al volver.
class SintomasScreen extends StatefulWidget {
  const SintomasScreen({super.key, required this.viewModel});

  final SintomasViewModel viewModel;

  @override
  State<SintomasScreen> createState() => _SintomasScreenState();
}

class _SintomasScreenState extends State<SintomasScreen> {
  static const lineasDescripcion = 3;

  final _descripcionControlador = TextEditingController();
  late final AppLifecycleListener _cicloDeVida;

  SintomasViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel
      ..cargarBorrador()
      ..addListener(_sincronizarDescripcion);
    _sincronizarDescripcion();
    _cicloDeVida = AppLifecycleListener(
      onHide: _viewModel.guardarBorrador,
      onResume: _viewModel.cargarBorrador,
    );
  }

  @override
  void dispose() {
    _viewModel.removeListener(_sincronizarDescripcion);
    _cicloDeVida.dispose();
    _descripcionControlador.dispose();
    super.dispose();
  }

  void _sincronizarDescripcion() {
    final descripcion = _viewModel.descripcion;
    if (_descripcionControlador.text == descripcion) return;
    _descripcionControlador.value = TextEditingValue(
      text: descripcion,
      selection: TextSelection.collapsed(offset: descripcion.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de síntomas')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensiones.separacion),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: Dimensiones.anchoMaximoContenido,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registro de síntomas',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: Dimensiones.separacionChica),
                    const Text(
                      'Seleccioná los síntomas que estás experimentando.',
                    ),
                    const SizedBox(height: Dimensiones.separacion),
                    SeleccionSintomas(
                      sintomas: SintomasViewModel.sintomasDisponibles,
                      seleccionados: _viewModel.sintomasSeleccionados,
                      onAlternar: _viewModel.alternarSintoma,
                    ),
                    const SizedBox(height: Dimensiones.separacionGrande),
                    const _Subtitulo(texto: 'Descripción adicional'),
                    TextField(
                      controller: _descripcionControlador,
                      maxLines: lineasDescripcion,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Describí cómo te sentís...',
                      ),
                      onChanged: _viewModel.cambiarDescripcion,
                    ),
                    const SizedBox(height: Dimensiones.separacionGrande),
                    const _Subtitulo(texto: '¿Desde cuándo?'),
                    SegmentedButton<DuracionSintomas>(
                      segments: [
                        for (final duracion in DuracionSintomas.values)
                          ButtonSegment(
                            value: duracion,
                            label: Text(duracion.etiqueta),
                          ),
                      ],
                      selected: {_viewModel.duracion},
                      onSelectionChanged: (seleccion) =>
                          _viewModel.cambiarDuracion(seleccion.first),
                    ),
                    const SizedBox(height: Dimensiones.separacionGrande),
                    const _Subtitulo(texto: 'Intensidad de los síntomas'),
                    Slider(
                      value: _viewModel.intensidad,
                      min: SintomasViewModel.intensidadMinima,
                      max: SintomasViewModel.intensidadMaxima,
                      divisions: _viewModel.divisionesIntensidad,
                      label: _viewModel.intensidadEtiqueta,
                      onChanged: _viewModel.cambiarIntensidad,
                    ),
                    Text(_viewModel.intensidadTexto),
                    const SizedBox(height: Dimensiones.separacionGrande),
                    if (_viewModel.tieneSignosAlarma) const AvisoAlarma(),
                    const SizedBox(height: Dimensiones.separacion),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _viewModel.registrarSintomas,
                        child: const Text('Registrar síntomas'),
                      ),
                    ),
                    if (_viewModel.estaRegistrado)
                      ConfirmacionSintomas(
                        esUrgente: _viewModel.muestraRegistroUrgente,
                      ),
                    const SizedBox(height: Dimensiones.separacion),
                    if (_viewModel.puedeSolicitarTurno)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            Rutas.solicitarTurno,
                          ),
                          child: const Text('Solicitar turno'),
                        ),
                      ),
                    const SizedBox(height: Dimensiones.separacionGrande),
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

class _Subtitulo extends StatelessWidget {
  const _Subtitulo({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensiones.separacionChica),
      child: Text(texto, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
