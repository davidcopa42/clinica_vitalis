import 'package:flutter/material.dart';

import '../../../domain/models/paciente.dart';
import '../../../domain/models/turno.dart';
import '../../core/formato.dart';

class TurnoConfirmadoScreen extends StatefulWidget {
  const TurnoConfirmadoScreen({
    super.key,
    required this.paciente,
    required this.turno,
    required this.alActivarAvisos,
  });

  final Paciente paciente;
  final Turno turno;

  /// Pide el permiso de recordatorios y devuelve el aviso para mostrar.
  final Future<String> Function() alActivarAvisos;

  @override
  State<TurnoConfirmadoScreen> createState() => _TurnoConfirmadoScreenState();
}

class _TurnoConfirmadoScreenState extends State<TurnoConfirmadoScreen>
    with SingleTickerProviderStateMixin {
  static const _duracionAparicion = Duration(milliseconds: 800);

  late final AnimationController _controladorAparicion;
  late final Animation<double> _opacidad;

  Paciente get paciente => widget.paciente;
  Turno get turno => widget.turno;

  @override
  void initState() {
    super.initState();
    _controladorAparicion = AnimationController(
      vsync: this,
      duration: _duracionAparicion,
    )..forward();
    _opacidad = CurvedAnimation(
      parent: _controladorAparicion,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controladorAparicion.dispose();
    super.dispose();
  }

  /// Pide el permiso en contexto, cuando el paciente entiende para qué
  /// sirve. Si lo niega, la app sigue funcionando.
  Future<void> _activarAvisos() async {
    final aviso = await widget.alActivarAvisos();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(aviso)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clínica Vitalis',
        ),
      ),
      body: FadeTransition(
        opacity: _opacidad,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.check_circle,
                  size: 70,
                ),
              ),
              const SizedBox(height: 15),
              const Center(
                child: Text(
                  'Turno confirmado',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'El turno fue registrado correctamente.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Datos del paciente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Nombre'),
                      subtitle: Text(
                        paciente.nombre,
                      ),
                    ),
                    ListTile(
                      title: const Text('Apellido'),
                      subtitle: Text(
                        paciente.apellido,
                      ),
                    ),
                    ListTile(
                      title: const Text('Correo'),
                      subtitle: Text(
                        paciente.correo,
                      ),
                    ),
                    ListTile(
                      title: const Text('Teléfono'),
                      subtitle: Text(
                        paciente.telefono,
                      ),
                    ),
                    if (paciente.obraSocial != null &&
                        paciente.obraSocial!.isNotEmpty)
                      ListTile(
                        title: const Text('Obra social'),
                        subtitle: Text(paciente.obraSocial!),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Datos del turno',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Especialidad'),
                      subtitle: Text(
                        turno.especialidad,
                      ),
                    ),
                    ListTile(
                      title: const Text('Profesional'),
                      subtitle: Text(
                        turno.profesional,
                      ),
                    ),
                    ListTile(
                      title: const Text('Fecha'),
                      subtitle: Text(
                        formatearFecha(turno.fecha),
                      ),
                    ),
                    ListTile(
                      title: const Text('Horario'),
                      subtitle: Text(
                        turno.horario,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _activarAvisos,
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('Avisarme un día antes'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      (route) => route.isFirst,
                    );
                  },
                  child: const Text(
                    'Volver al inicio',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
