import 'package:flutter/material.dart';

import '../../../domain/models/registro_clinico.dart';
import '../../core/dimensiones.dart';
import '../../core/formato.dart';
import 'tipo_registro_ui.dart';

/// Tarjeta resumida de un registro clinico.
class RegistroClinicoCard extends StatelessWidget {
  const RegistroClinicoCard({
    super.key,
    required this.registro,
    required this.onTap,
  });

  static const tamanioIcono = 32.0;

  final RegistroClinico registro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensiones.separacionMedia,
        vertical: Dimensiones.separacionMinima,
      ),
      child: ListTile(
        leading: Icon(registro.tipo.icono, size: tamanioIcono),
        title: Text(registro.titulo),
        subtitle: Text(
          '${registro.profesional}\n${formatearFecha(registro.fecha)}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
