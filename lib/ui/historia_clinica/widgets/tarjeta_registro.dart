import 'package:flutter/material.dart';

import '../../../domain/models/registro_clinico.dart';
import '../view_models/textos_registro_clinico.dart';

/// Tarjeta de un registro de la historia clínica.
class TarjetaRegistro extends StatelessWidget {
  const TarjetaRegistro({
    super.key,
    required this.registro,
    required this.alTocar,
  });

  final RegistroClinico registro;
  final VoidCallback alTocar;

  static const _iconosPorTipo = {
    TipoRegistro.analisis: Icons.science,
    TipoRegistro.estudio: Icons.medical_information,
    TipoRegistro.receta: Icons.description,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ListTile(
        leading: Icon(
          _iconosPorTipo[registro.tipo],
          size: 32,
        ),
        title: Text(registro.titulo),
        subtitle: Text(registro.resumenTexto),
        isThreeLine: true,
        trailing: const Icon(
          Icons.arrow_forward_ios,
        ),
        onTap: alTocar,
      ),
    );
  }
}
