import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';
import 'tarjeta_informacion.dart';

/// Pantalla con informacion general de la clinica.
class InformacionScreen extends StatelessWidget {
  const InformacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensiones.separacion),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Dimensiones.anchoMaximoContenido,
            ),
            child: const Column(
              children: [
                TarjetaInformacion(
                  icono: Icons.location_on,
                  titulo: 'Dirección',
                  detalle: 'Av. Siempre Viva 742, Mendoza.',
                ),
                TarjetaInformacion(
                  icono: Icons.schedule,
                  titulo: 'Horarios de atención',
                  detalle: 'Lunes a viernes de 8:00 a 20:00.\n'
                      'Sábados de 9:00 a 13:00.',
                ),
                TarjetaInformacion(
                  icono: Icons.local_hospital,
                  titulo: 'Guardia',
                  detalle: 'Atención las 24 horas.\nTeléfono de guardia: 107.',
                ),
                TarjetaInformacion(
                  icono: Icons.medical_services,
                  titulo: 'Especialidades',
                  detalle: 'Cardiología, Pediatría, Traumatología, '
                      'Dermatología y Clínica médica.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
