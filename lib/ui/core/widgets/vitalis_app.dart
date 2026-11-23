import 'package:flutter/material.dart';

import '../tema_app.dart';

/// Raiz de la app: tema, pantalla inicial y generador de rutas.
class VitalisApp extends StatelessWidget {
  const VitalisApp({
    super.key,
    required this.pantallaInicial,
    required this.generarRuta,
  });

  final Widget pantallaInicial;
  final RouteFactory generarRuta;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clínica Vitalis',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro,
      darkTheme: TemaApp.oscuro,
      themeMode: ThemeMode.system,
      home: pantallaInicial,
      onGenerateRoute: generarRuta,
    );
  }
}
