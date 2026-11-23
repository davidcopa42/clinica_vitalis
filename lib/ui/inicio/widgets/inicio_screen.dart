import 'package:flutter/material.dart';

import '../../../dependencias.dart';
import '../../../domain/models/paciente.dart';
import '../../conectividad/view_models/conectividad_view_model.dart';
import '../../core/duraciones.dart';
import '../../historia_clinica/view_models/historia_clinica_view_model.dart';
import '../../historia_clinica/widgets/historia_clinica_screen.dart';
import '../../informacion/widgets/informacion_screen.dart';
import '../../perfil/view_models/perfil_view_model.dart';
import '../../perfil/widgets/perfil_screen.dart';
import '../../sintomas/view_models/sintomas_view_model.dart';
import '../../sintomas/widgets/sintomas_screen.dart';
import '../../turnos/view_models/mis_turnos_view_model.dart';
import '../../turnos/view_models/turno_view_model.dart';
import '../../turnos/widgets/mis_turnos_screen.dart';
import '../../turnos/widgets/solicitar_turno_screen.dart';
import '../view_models/inicio_view_model.dart';
import 'panel_inicio.dart';

class InicioScreen extends StatefulWidget {
  final Paciente paciente;
  final Dependencias dependencias;

  // Los crea y los descarta PuertaSesion.
  final InicioViewModel inicioViewModel;
  final PerfilViewModel perfilViewModel;
  final ConectividadViewModel conectividadViewModel;

  const InicioScreen({
    super.key,
    required this.paciente,
    required this.dependencias,
    required this.inicioViewModel,
    required this.perfilViewModel,
    required this.conectividadViewModel,
  });

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int _indiceSeleccionado = 0;

  InicioViewModel get _inicioViewModel => widget.inicioViewModel;
  PerfilViewModel get _perfilViewModel => widget.perfilViewModel;
  ConectividadViewModel get _conectividadViewModel =>
      widget.conectividadViewModel;

  @override
  void initState() {
    super.initState();
    _inicioViewModel.addListener(_mostrarAvisoPendiente);
  }

  /// Crea el ViewModel de Solicitar turno y abre la pantalla.
  void _abrirSolicitarTurno() {
    final dependencias = widget.dependencias;
    final viewModel = TurnoViewModel(
      repositorio: dependencias.turnoRepository,
      borradorRepository: dependencias.borradorRepository,
      recordatorioRepository: dependencias.recordatorioRepository,
      busDeEventos: dependencias.busDeEventos,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SolicitarTurnoScreen(
          paciente: widget.paciente,
          viewModel: viewModel,
        ),
      ),
    );
  }

  /// Crea el ViewModel de Mis turnos y abre la pantalla.
  void _abrirMisTurnos() {
    final dependencias = widget.dependencias;
    final viewModel = MisTurnosViewModel(
      repositorio: dependencias.turnoRepository,
      recordatorioRepository: dependencias.recordatorioRepository,
      busDeEventos: dependencias.busDeEventos,
      pacienteUid: widget.paciente.uid,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MisTurnosScreen(
          paciente: widget.paciente,
          viewModel: viewModel,
        ),
      ),
    );
  }

  /// Crea el ViewModel de Registro de síntomas y abre la pantalla.
  void _abrirSintomas() {
    final viewModel = SintomasViewModel(
      borradorRepository: widget.dependencias.borradorRepository,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SintomasScreen(
          viewModel: viewModel,
          onSolicitarTurno: _abrirSolicitarTurno,
        ),
      ),
    );
  }

  /// Crea el ViewModel de Historia clínica y abre la pantalla.
  void _abrirHistoriaClinica() {
    final viewModel = HistoriaClinicaViewModel(
      repositorio: widget.dependencias.historiaClinicaRepository,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoriaClinicaScreen(
          paciente: widget.paciente,
          viewModel: viewModel,
        ),
      ),
    );
  }

  /// Abre el perfil, o avisa si el paciente no está identificado.
  void _abrirPerfil() {
    if (!_inicioViewModel.puedeAbrirPerfil) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no identificado')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerfilScreen(
          uid: widget.paciente.uid,
          viewModel: _perfilViewModel,
        ),
      ),
    );
  }

  /// Muestra el SnackBar verde cuando el ViewModel deja un aviso.
  void _mostrarAvisoPendiente() {
    final aviso = _inicioViewModel.avisoPendiente;
    if (aviso == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(aviso),
        backgroundColor: Colors.green,
        duration: duracionAvisoLargo,
      ),
    );
    _inicioViewModel.descartarAviso();
  }

  @override
  void dispose() {
    _inicioViewModel.removeListener(_mostrarAvisoPendiente);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pantallas = [
      PanelInicio(
        saludo: _inicioViewModel.saludo,
        fotoUrl: _inicioViewModel.fotoParaMostrar,
        conectividadViewModel: _conectividadViewModel,
        alTocarAvatar: _abrirPerfil,
        alSolicitarTurno: _abrirSolicitarTurno,
        alAbrirMisTurnos: _abrirMisTurnos,
        alRegistrarSintomas: _abrirSintomas,
        alAbrirHistoriaClinica: _abrirHistoriaClinica,
      ),
      const InformacionScreen(),
      PerfilScreen(
        uid: widget.paciente.uid,
        viewModel: _perfilViewModel,
      ),
    ];

    return Scaffold(
      body: pantallas[_indiceSeleccionado],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSeleccionado,
        onDestinationSelected: (indice) {
          setState(() {
            _indiceSeleccionado = indice;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            label: 'Información',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
