import 'package:flutter/material.dart';

/// Fila con la etiqueta de un dato y su valor, con icono opcional.
class FilaDato extends StatelessWidget {
  const FilaDato({
    super.key,
    required this.etiqueta,
    required this.valor,
    this.icono,
  });

  final String etiqueta;
  final String valor;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    final icono = this.icono;
    return ListTile(
      leading: icono == null
          ? null
          : Icon(icono, color: Theme.of(context).colorScheme.primary),
      title: Text(etiqueta),
      subtitle: Text(
        valor,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}
