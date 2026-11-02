import 'package:flutter/material.dart';
import 'package:clinica_vitalis/domain/models/registro_clinico.dart';

/// Muestra los detalles de un registro clínico.
class DetalleRegistroPage extends StatelessWidget {
  const DetalleRegistroPage({
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
              _nombreTipo(registro.tipo),
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
            Text(
              '${registro.fecha.day}/'
              '${registro.fecha.month}/'
              '${registro.fecha.year}',
            ),
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

  String _nombreTipo(TipoRegistro tipo) {
    switch (tipo) {
      case TipoRegistro.analisis:
        return 'Análisis';
      case TipoRegistro.estudio:
        return 'Estudio';
      case TipoRegistro.receta:
        return 'Receta';
    }
  }
}
