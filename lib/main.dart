import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/repositories/perfil_repository.dart';
import 'providers/perfil_provider.dart';
import 'ui/perfil/widgets/perfil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PerfilProvider(
            repository: PerfilRepository(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clínica Vitalis',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PerfilScreen(uid: 'usuario_prueba_123'),
    );
  }
}