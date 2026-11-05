import 'package:flutter/material.dart';

import 'package:clinica_vitalis/data/repositories/historia_clinica_repository.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/registro_clinico.dart';
import 'package:clinica_vitalis/ui/historia_clinica/view_models/historia_clinica_view_model.dart';
import 'package:clinica_vitalis/ui/historia_clinica/widgets/detalle_registro_page.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';

/// Pantalla que muestra la historia clínica del paciente.
class HistoriaClinicaPage extends StatefulWidget {
  const HistoriaClinicaPage({
    super.key,
    required this.paciente,
  });

  final Paciente paciente;

  @override
  State<HistoriaClinicaPage> createState() => _HistoriaClinicaPageState();
}

class _HistoriaClinicaPageState extends State<HistoriaClinicaPage> {
  late final HistoriaClinicaViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = HistoriaClinicaViewModel(
      repositorio: HistoriaClinicaRepository(),
    );

    _viewModel.cargar(widget.paciente.correo);
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
        title: const Text('Historia clínica'),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return _construirContenido();
        },
      ),
    );
  }

  Widget _construirContenido() {
    switch (_viewModel.estado) {
      case EstadoCarga.inicial:
      case EstadoCarga.cargando:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case EstadoCarga.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              Text(
                _viewModel.mensajeError ?? 'Ocurrió un error.',
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _viewModel.reintentar,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );

      case EstadoCarga.exito:
        return _construirLista();
    }
  }

  Widget _construirLista() {
    final registros = _viewModel.registrosFiltrados;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<TipoRegistro?>(
            segments: const [
              ButtonSegment(
                value: null,
                label: Text('Todos'),
              ),
              ButtonSegment(
                value: TipoRegistro.analisis,
                label: Text('Análisis'),
              ),
              ButtonSegment(
                value: TipoRegistro.estudio,
                label: Text('Estudios'),
              ),
              ButtonSegment(
                value: TipoRegistro.receta,
                label: Text('Recetas'),
              ),
            ],
            selected: {_viewModel.filtro},
            onSelectionChanged: (seleccion) {
              _viewModel.cambiarFiltro(seleccion.first);
            },
          ),
        ),
        Expanded(
          child: registros.isEmpty
              ? const Center(
                  child: Text('No hay registros para este filtro.'),
                )
              : ListView.builder(
                  itemCount: registros.length,
                  itemBuilder: (context, index) {
                    final registro = registros[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: Icon(
                          _obtenerIcono(registro.tipo),
                          size: 32,
                        ),
                        title: Text(registro.titulo),
                        subtitle: Text(
                          '${registro.profesional}\n'
                          '${registro.fecha.day}/'
                          '${registro.fecha.month}/'
                          '${registro.fecha.year}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetalleRegistroPage(
                                registro: registro,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  IconData _obtenerIcono(TipoRegistro tipo) {
    switch (tipo) {
      case TipoRegistro.analisis:
        return Icons.science;
      case TipoRegistro.estudio:
        return Icons.medical_information;
      case TipoRegistro.receta:
        return Icons.description;
    }
  }
}
