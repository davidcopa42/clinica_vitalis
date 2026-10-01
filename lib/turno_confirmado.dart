import 'package:flutter/material.dart';

import 'paciente.dart';
import 'turno.dart';

class TurnoConfirmadoPage extends StatelessWidget {
  const TurnoConfirmadoPage({
    super.key,
    required this.paciente,
    required this.turno,
  });

  final Paciente paciente;
  final Turno turno;

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clínica Vitalis',
        ),
      ),

      body: SingleChildScrollView(
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
                      _formatearFecha(turno.fecha),
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
    );
  }
}