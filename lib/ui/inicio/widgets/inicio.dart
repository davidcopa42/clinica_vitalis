import 'package:flutter/material.dart';

import '../../../dependencias.dart';
import '../../../domain/models/paciente.dart';
import '../../auth/view_models/sesion_view_model.dart';
import '../../conectividad/view_models/conectividad_view_model.dart';
import '../../conectividad/widgets/aviso_sin_conexion.dart';
import '../../historia_clinica/view_models/historia_clinica_view_model.dart';
import '../../historia_clinica/widgets/historia_clinica_page.dart';
import '../../informacion/widgets/informacion_page.dart';
import '../../perfil/view_models/perfil_view_model.dart';
import '../../perfil/widgets/perfil.dart';
import '../../sintomas/view_models/sintomas_view_model.dart';
import '../../sintomas/widgets/sintomas_page.dart';
import '../../turnos/view_models/mis_turnos_view_model.dart';
import '../../turnos/view_models/turno_view_model.dart';
import '../../turnos/widgets/mis_turnos.dart';
import '../../turnos/widgets/solicitar_turno.dart';
import '../view_models/inicio_view_model.dart';

class InicioPage extends StatefulWidget {
  final Paciente paciente;
  final SesionViewModel sesion;
  final Dependencias dependencias;

  // Los crea y los descarta PuertaSesion.
  final InicioViewModel inicioViewModel;
  final PerfilViewModel perfilViewModel;
  final ConectividadViewModel conectividadViewModel;

  const InicioPage({
    super.key,
    required this.paciente,
    required this.sesion,
    required this.dependencias,
    required this.inicioViewModel,
    required this.perfilViewModel,
    required this.conectividadViewModel,
  });

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
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
        builder: (context) => TurnoPage(
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
        builder: (context) => MisTurnosPage(
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
        builder: (context) => SintomasPage(
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
        builder: (context) => HistoriaClinicaPage(
          paciente: widget.paciente,
          viewModel: viewModel,
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
        duration: const Duration(seconds: 4),
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
      _buildContenidoInicio(context),
      _buildInformacionTab(),
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

  Widget _buildContenidoInicio(BuildContext context) {
    final fotoUrl = _inicioViewModel.fotoUrl;
    final nombreUsuario = _inicioViewModel.nombreUsuario;
    final uidActual = widget.paciente.uid;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo_vitalis.png',
            fit: BoxFit.contain,
          ),
        ),
        title: const Text('Clínica Vitalis'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                if (uidActual.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PerfilScreen(
                        uid: uidActual,
                        viewModel: _perfilViewModel,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Error: Usuario no identificado')),
                  );
                }
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue.shade100,
                backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty)
                    ? NetworkImage(fotoUrl)
                    : null,
                child: (fotoUrl == null || fotoUrl.isEmpty)
                    ? const Icon(Icons.person, color: Colors.blue, size: 20)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Colocamos el aviso de sin conexión justo arriba de todo en el cuerpo
          AvisoSinConexion(viewModel: _conectividadViewModel),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  const Icon(
                    Icons.local_hospital,
                    size: 70,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hola, $nombreUsuario',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 35),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.calendar_month,
                      ),
                      title: const Text(
                        'Solicitar un turno',
                      ),
                      subtitle: const Text(
                        'Elegí una especialidad, profesional y horario.',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: _abrirSolicitarTurno,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.event_available),
                      title: const Text('Mis turnos'),
                      subtitle: const Text('Consultá y cancelá tus turnos.'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _abrirMisTurnos,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.medical_information),
                      title: const Text('Registrar síntomas'),
                      subtitle: const Text(
                        'Contanos cómo te sentís y recibí una recomendación.',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _abrirSintomas,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.description,
                      ),
                      title: const Text(
                        'Historia clínica',
                      ),
                      subtitle: const Text(
                        'Consultá tu información clínica.',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: _abrirHistoriaClinica,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformacionTab() {
    return const InformacionPage();
  }
}