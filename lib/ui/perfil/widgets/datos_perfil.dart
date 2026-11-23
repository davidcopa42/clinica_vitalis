import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';
import '../../core/widgets/avatar_paciente.dart';
import '../../core/widgets/fila_dato.dart';
import '../view_models/perfil_view_model.dart';

/// Foto, correo y datos personales del paciente.
class DatosPerfil extends StatelessWidget {
  const DatosPerfil({super.key, required this.viewModel});

  static const radioAvatar = 50.0;

  final PerfilViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: AvatarPaciente(
            fotoUrl: viewModel.fotoUrl,
            radio: radioAvatar,
          ),
        ),
        const SizedBox(height: Dimensiones.separacionMedia),
        Text(
          viewModel.correoTexto,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: Dimensiones.separacionExtra),
        FilaDato(
          icono: Icons.person,
          etiqueta: 'Nombre Completo',
          valor: viewModel.nombreCompletoTexto,
        ),
        FilaDato(
          icono: Icons.badge,
          etiqueta: 'DNI',
          valor: viewModel.dniTexto,
        ),
        FilaDato(
          icono: Icons.calendar_today,
          etiqueta: 'Nacimiento',
          valor: viewModel.nacimientoTexto,
        ),
        FilaDato(
          icono: Icons.phone,
          etiqueta: 'Teléfono',
          valor: viewModel.telefonoTexto,
        ),
        FilaDato(
          icono: Icons.medical_services,
          etiqueta: 'Obra Social',
          valor: viewModel.obraSocialTexto,
        ),
      ],
    );
  }
}
