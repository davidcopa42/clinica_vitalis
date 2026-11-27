import 'package:flutter/material.dart';

/// Una fila del perfil: ícono, etiqueta y el valor ya formateado.
class FilaDatoPerfil extends StatelessWidget {
  const FilaDatoPerfil({
    super.key,
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icono, color: Colors.blue, size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(etiqueta,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              Text(valor,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
