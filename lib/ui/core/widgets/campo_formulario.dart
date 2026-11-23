import 'package:flutter/material.dart';

/// Campo de texto con borde, etiqueta e icono, usado en todos los formularios.
class CampoFormulario extends StatelessWidget {
  const CampoFormulario({
    super.key,
    required this.controlador,
    required this.etiqueta,
    this.icono,
    this.validador,
    this.tipoTeclado,
    this.ocultarTexto = false,
    this.soloLectura = false,
    this.onTap,
  });

  final TextEditingController controlador;
  final String etiqueta;
  final IconData? icono;
  final FormFieldValidator<String>? validador;
  final TextInputType? tipoTeclado;
  final bool ocultarTexto;
  final bool soloLectura;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icono = this.icono;
    return TextFormField(
      controller: controlador,
      keyboardType: tipoTeclado,
      obscureText: ocultarTexto,
      readOnly: soloLectura,
      onTap: onTap,
      validator: validador,
      decoration: InputDecoration(
        labelText: etiqueta,
        border: const OutlineInputBorder(),
        prefixIcon: icono == null ? null : Icon(icono),
      ),
    );
  }
}
