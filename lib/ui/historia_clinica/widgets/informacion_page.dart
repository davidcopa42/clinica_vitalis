import 'package:flutter/material.dart';

/// Muestra la información general de Clínica Vitalis.
class InformacionPage extends StatelessWidget {
  const InformacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Clínica Vitalis',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Información general del centro de salud.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _crearTarjeta(
                icono: Icons.location_on,
                titulo: 'Dirección',
                contenido: 'Dirección de ejemplo - completar con la real.',
              ),
              _crearTarjeta(
                icono: Icons.access_time,
                titulo: 'Horarios de atención',
                contenido: 'Lunes a viernes: 08:00 a 20:00 hs.',
              ),
              _crearTarjeta(
                icono: Icons.phone,
                titulo: 'Teléfono de guardia',
                contenido: '107',
              ),
              _crearTarjeta(
                icono: Icons.medical_services,
                titulo: 'Especialidades',
                contenido: 'Clínica médica\n'
                    'Cardiología\n'
                    'Pediatría\n'
                    'Traumatología\n'
                    'Ginecología',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _crearTarjeta({
    required IconData icono,
    required String titulo,
    required String contenido,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(contenido),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
