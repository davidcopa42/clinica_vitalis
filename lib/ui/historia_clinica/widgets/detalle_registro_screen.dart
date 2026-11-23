import 'package:flutter/material.dart';

import '../../../domain/models/registro_clinico.dart';
import '../../core/dimensiones.dart';
import '../../core/formato.dart';
import '../../core/widgets/fila_dato.dart';
import 'tipo_registro_ui.dart';

/// Pantalla con el detalle completo de un registro clinico.
class DetalleRegistroScreen extends StatelessWidget {
  const DetalleRegistroScreen({super.key, required this.registro});

  final RegistroClinico registro;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del registro')),
      body: ListView(
        padding: const EdgeInsets.all(Dimensiones.margenContenido),
        children: [
          Text(registro.tipo.nombre, style: estilos.labelLarge),
          const SizedBox(height: Dimensiones.separacionMedia),
          Text(registro.titulo, style: estilos.headlineSmall),
          const Divider(height: Dimensiones.separacionSeccion),
          FilaDato(etiqueta: 'Fecha', valor: formatearFecha(registro.fecha)),
          FilaDato(etiqueta: 'Profesional', valor: registro.profesional),
          FilaDato(etiqueta: 'Detalle', valor: registro.detalle),
        ],
      ),
    );
  }
}
