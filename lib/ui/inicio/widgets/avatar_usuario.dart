import 'package:flutter/material.dart';

/// Foto del usuario en la barra superior; sin foto muestra un ícono.
class AvatarUsuario extends StatelessWidget {
  const AvatarUsuario({
    super.key,
    required this.fotoUrl,
    required this.alTocar,
  });

  /// Foto a mostrar, o null para el ícono genérico.
  final String? fotoUrl;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final foto = fotoUrl;
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: alTocar,
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.blue.shade100,
          backgroundImage: foto == null ? null : NetworkImage(foto),
          child: foto == null
              ? const Icon(Icons.person, color: Colors.blue, size: 20)
              : null,
        ),
      ),
    );
  }
}
