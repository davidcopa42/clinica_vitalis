import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/perfil_repository.dart';
import 'data/services/notificaciones_service.dart';
import 'providers/perfil_provider.dart';
import 'ui/auth/view_models/sesion_view_model.dart';
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
    final authRepository = AuthRepository();
    final perfilRepository = PerfilRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PerfilProvider(
            repository: perfilRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SesionViewModel(
            authRepo: authRepository,
            perfilRepo: perfilRepository,
          ),
        ),
      ],
      child: const MaterialApp(
        title: 'Clínica Vitalis',
        debugShowCheckedModeBanner: false,
        home: PuertaSesion(),
      ),
    );
  }
}