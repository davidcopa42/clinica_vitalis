import 'package:flutter/material.dart';

/// Tarjeta de una acción del inicio: ícono, título, descripción y flecha.
class TarjetaAccion extends StatelessWidget {
  const TarjetaAccion({
    super.key,
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.alTocar,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icono),
        title: Text(titulo),
        subtitle: Text(descripcion),
        trailing: const Icon(Icons.chevron_right),
        onTap: alTocar,
      ),
    );
  }
}
