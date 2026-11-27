import 'package:clinica_vitalis/domain/models/registro_clinico.dart';
import 'package:flutter/material.dart';

import '../view_models/textos_registro_clinico.dart';

/// Muestra los detalles de un registro clínico.
class DetalleRegistroScreen extends StatelessWidget {
  const DetalleRegistroScreen({
    super.key,
    required this.registro,
  });

  final RegistroClinico registro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              registro.tipoTexto,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            Text(
              registro.titulo,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(height: 32),
            const Text(
              'Fecha',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(registro.fechaTexto),
            const SizedBox(height: 20),
            const Text(
              'Profesional',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(registro.profesional),
            const SizedBox(height: 20),
            const Text(
              'Detalle',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(registro.detalle),
          ],
        ),
      ),
    );
  }
}
