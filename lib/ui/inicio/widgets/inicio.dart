import 'package:flutter/material.dart';

import '../../historia_clinica/widgets/historia_clinica.dart';
import '../../registro/widgets/registro.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int _indiceSeleccionado = 0;

  void _seleccionarSeccion(int indice) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clínica Vitalis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Icon(
              Icons.local_hospital,
              size: 70,
            ),

            const SizedBox(height: 12),

            const Text(
              'Bienvenido a Clínica Vitalis',
              style: TextStyle(
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
                      builder: (context) => const RegistroPage(),
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
                      builder: (context) =>
                      const HistoriaClinicaPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSeleccionado,
        onDestinationSelected: _seleccionarSeccion,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            label: 'Información',
          ),
        ],
      ),
    );
  }
}