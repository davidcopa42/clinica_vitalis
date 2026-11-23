import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';

/// Tarjeta con un dato general de la clinica.
class TarjetaInformacion extends StatelessWidget {
  const TarjetaInformacion({
    super.key,
    required this.icono,
    required this.titulo,
    required this.detalle,
  });

  final IconData icono;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: Dimensiones.separacionMedia),
      child: ListTile(
        leading: Icon(icono, color: Theme.of(context).colorScheme.primary),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(detalle),
      ),
    );
  }
}
