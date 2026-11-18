import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'data/services/notificaciones_service.dart';
import 'data/services/tareas_background_service.dart';
import 'ui/auth/widgets/puerta_sesion.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificacionesService().inicializar();

  // Si WorkManager falla, la app tiene que abrir igual: la limpieza
  // de turnos vencidos no es imprescindible para usarla.
  try {
    await TareasBackgroundService().inicializar();
  } catch (error) {
    debugPrint('No se pudo programar la tarea en background: $error');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color semilla = Colors.blue;
    return MaterialApp(
      title: 'Clínica Vitalis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: semilla,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: semilla,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const PuertaSesion(),
    );
  }
}
