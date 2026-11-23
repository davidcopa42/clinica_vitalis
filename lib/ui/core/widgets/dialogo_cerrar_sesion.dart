import 'package:flutter/material.dart';

/// Dialogo que pide confirmar el cierre de sesion.
///
/// Se cierra devolviendo true si el usuario confirma.
class DialogoCerrarSesion extends StatelessWidget {
  const DialogoCerrarSesion({super.key});

  /// Muestra el dialogo y devuelve true si el usuario confirma.
  static Future<bool> confirmar(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => const DialogoCerrarSesion(),
    );
    return confirmado ?? false;
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
