import 'package:flutter/material.dart';

/// Foto circular del paciente, o un icono si no tiene foto.
class AvatarPaciente extends StatelessWidget {
  const AvatarPaciente({super.key, required this.fotoUrl, required this.radio});

  final String? fotoUrl;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final fotoUrl = this.fotoUrl;
    final tieneFoto = fotoUrl != null && fotoUrl.isNotEmpty;
    return CircleAvatar(
      radius: radio,
      backgroundColor: Colors.blue.shade100,
      backgroundImage: tieneFoto ? NetworkImage(fotoUrl) : null,
      child: tieneFoto
          ? null
          : Icon(Icons.person, size: radio, color: Colors.blue),
    );
  }
}
