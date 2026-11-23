import 'package:flutter/material.dart';

/// Diálogo que pide confirmar el cierre de sesión.
class DialogoCerrarSesion extends StatelessWidget {
  const DialogoCerrarSesion({super.key});

  /// Muestra el diálogo y devuelve true solo si el usuario eligió Salir.
  static Future<bool> confirmar(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => const DialogoCerrarSesion(),
    );
    return confirmado == true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cerrar sesión'),
      content: const Text('¿Estás seguro de que deseas salir?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Salir', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
