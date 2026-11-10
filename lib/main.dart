import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'data/services/notificaciones_service.dart';
import 'ui/auth/widgets/puerta_sesion.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificacionesService().inicializar();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Clínica Vitalis',
      debugShowCheckedModeBanner: false,
      home: PuertaSesion(),
    );
  }
}
