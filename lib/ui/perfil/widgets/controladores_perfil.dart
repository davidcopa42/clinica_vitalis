import 'package:flutter/material.dart';

import '../view_models/formulario_perfil_view_model.dart';

/// Agrupa los controladores de texto del formulario de perfil.
class ControladoresPerfil {
  final nombre = TextEditingController();
  final apellido = TextEditingController();
  final dni = TextEditingController();
  final fechaNacimiento = TextEditingController();
  final telefono = TextEditingController();
  final numeroAfiliado = TextEditingController();

  /// Copia en los campos los valores iniciales del [viewModel].
  void cargarDesde(FormularioPerfilViewModel viewModel) {
    nombre.text = viewModel.nombreInicial;
    apellido.text = viewModel.apellidoInicial;
    dni.text = viewModel.dniInicial;
    telefono.text = viewModel.telefonoInicial;
    numeroAfiliado.text = viewModel.numeroAfiliadoInicial;
    fechaNacimiento.text = viewModel.fechaNacimientoTexto;
  }

  /// Envia los valores del formulario al [viewModel] para guardarlos.
  Future<void> guardarEn(FormularioPerfilViewModel viewModel) {
    return viewModel.guardar(
      nombre: nombre.text.trim(),
      apellido: apellido.text.trim(),
      dni: dni.text.trim(),
      telefono: telefono.text.trim(),
      numeroAfiliado: numeroAfiliado.text.trim(),
    );
  }

  /// Libera todos los controladores.
  void dispose() {
    nombre.dispose();
    apellido.dispose();
    dni.dispose();
    fechaNacimiento.dispose();
    telefono.dispose();
    numeroAfiliado.dispose();
  }
}
