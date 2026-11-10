import 'package:flutter/material.dart';

/// Pantalla con información general de la clínica.
class InformacionPage extends StatelessWidget {
  const InformacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: const Column(
              children: [
                _TarjetaInformacion(
                  icono: Icons.location_on,
                  titulo: 'Dirección',
                  detalle: 'Av. Siempre Viva 742, Mendoza.',
                ),
                _TarjetaInformacion(
                  icono: Icons.schedule,
                  titulo: 'Horarios de atención',
                  detalle:
                  'Lunes a viernes de 8:00 a 20:00.\nSábados de 9:00 a 13:00.',
                ),
                _TarjetaInformacion(
                  icono: Icons.local_hospital,
                  titulo: 'Guardia',
                  detalle:
                  'Atención las 24 horas.\nTeléfono de guardia: 107.',
                ),
                _TarjetaInformacion(
                  icono: Icons.medical_services,
                  titulo: 'Especialidades',
                  detalle:
                  'Cardiología, Pediatría, Traumatología, Dermatología y Clínica médica.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaInformacion extends StatelessWidget {
  const _TarjetaInformacion({
    required this.icono,
    required this.titulo,
    required this.detalle,
  });

  final IconData icono;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icono,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(detalle),
      ),
    );
  }
}