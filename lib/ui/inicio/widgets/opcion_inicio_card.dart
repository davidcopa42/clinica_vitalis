import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';

/// Tarjeta del menu principal que abre una funcionalidad.
class OpcionInicioCard extends StatelessWidget {
  const OpcionInicioCard({
    super.key,
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: Dimensiones.separacionMedia),
      child: ListTile(
        leading: Icon(icono),
        title: Text(titulo),
        subtitle: Text(descripcion),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
