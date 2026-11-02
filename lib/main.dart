import 'package:flutter/material.dart';

import 'data/services/notificaciones_service.dart';
import 'ui/inicio/widgets/inicio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificacionesService().inicializar();

  runApp(const ClinicaVitalisApp());
}

class ClinicaVitalisApp extends StatelessWidget {
  const ClinicaVitalisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clínica Vitalis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const InicioPage(),
    );
  }
}
