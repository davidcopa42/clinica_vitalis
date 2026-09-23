import 'package:flutter/material.dart';

class HistoriaClinicaPage extends StatelessWidget {
  const HistoriaClinicaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clínica Vitalis',
        ),
      ),

      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_outlined,
                size: 70,
              ),

              SizedBox(height: 20),

              Text(
                'Historia clínica',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 12),

              Text(
                'No hay información disponible por el momento.\n\n'
                    'Esta sección será conectada posteriormente '
                    'con el sistema interno de la clínica.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}