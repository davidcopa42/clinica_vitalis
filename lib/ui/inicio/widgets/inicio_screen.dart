import 'package:flutter/material.dart';

import '../../conectividad/view_models/conectividad_view_model.dart';
import '../../informacion/widgets/informacion_screen.dart';
import '../view_models/inicio_view_model.dart';
import '../view_models/pestania_inicio.dart';
import 'panel_inicio.dart';

/// Pantalla principal con la barra de navegacion inferior.
class InicioScreen extends StatefulWidget {
  const InicioScreen({
    super.key,
    required this.viewModel,
    required this.conectividadViewModel,
    required this.pantallaPerfil,
  });

  static const duracionAviso = Duration(seconds: 4);

  final InicioViewModel viewModel;
  final ConectividadViewModel conectividadViewModel;
  final Widget pantallaPerfil;

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  InicioViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel
      ..addListener(_mostrarAviso)
      ..cargar();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_mostrarAviso);
    super.dispose();
  }

  void _mostrarAviso() {
    final aviso = _viewModel.aviso;
    if (aviso == null || !mounted) return;
    _viewModel.limpiarAviso();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(aviso),
        backgroundColor: Colors.green,
        duration: InicioScreen.duracionAviso,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final pestania = _viewModel.pestania;
        return Scaffold(
          body: switch (pestania) {
            PestaniaInicio.inicio => PanelInicio(
                viewModel: _viewModel,
                conectividadViewModel: widget.conectividadViewModel,
              ),
            PestaniaInicio.informacion => const InformacionScreen(),
            PestaniaInicio.perfil => widget.pantallaPerfil,
          },
          bottomNavigationBar: NavigationBar(
            selectedIndex: pestania.index,
            onDestinationSelected: (indice) =>
                _viewModel.seleccionarPestania(PestaniaInicio.values[indice]),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
              NavigationDestination(
                icon: Icon(Icons.info_outline),
                label: 'Información',
              ),
              NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
            ],
          ),
        );
      },
    );
  }
}
