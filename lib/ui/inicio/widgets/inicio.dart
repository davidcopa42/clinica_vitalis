import 'package:clinica_vitalis/data/repositories/perfil_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../domain/models/paciente.dart';
import '../../auth/view_models/sesion_view_model.dart';
import '../../historia_clinica/widgets/historia_clinica.dart';
import '../../perfil/view_models/perfil_view_model.dart';
import '../../perfil/widgets/perfil.dart';
import '../../sintomas/widgets/sintomas_page.dart';
import '../../turnos/widgets/mis_turnos.dart';
import '../../turnos/widgets/solicitar_turno.dart';

class InicioPage extends StatefulWidget {
  final Paciente paciente;
  final SesionViewModel sesion;

  const InicioPage({
    super.key,
    required this.paciente,
    required this.sesion,
  });

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int _indiceSeleccionado = 0;
  late final PerfilViewModel _perfilViewModel;

  @override
  void initState() {
    super.initState();
    _perfilViewModel = PerfilViewModel(repository: PerfilRepository());
  }

  @override
  void dispose() {
    _perfilViewModel.dispose();
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

          if (indice == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Clínica Vitalis - Centro de salud',
                ),
              ),
            );
          }
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
    final userAuth = FirebaseAuth.instance.currentUser;
    final fotoUrl = userAuth?.photoURL ?? widget.paciente.fotoUrl;
    final nombreUsuario =
        widget.paciente.nombre.isNotEmpty ? widget.paciente.nombre : 'Paciente';
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TurnoPage(
                        paciente: widget.paciente,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.event_available),
                title: const Text('Mis turnos'),
                subtitle: const Text('Consultá y cancelá tus turnos.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MisTurnosPage(
                        paciente: widget.paciente,
                      ),
                    ),
                  );
                },
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SintomasPage(
                        onSolicitarTurno: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TurnoPage(
                                paciente: widget.paciente,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoriaClinicaPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacionTab() {
    return Scaffold(
      appBar: AppBar(title: const Text('Información'), centerTitle: true),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'Clínica Vitalis - Centro de salud',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
