import 'package:flutter/material.dart';

import '../../../domain/models/paciente.dart';
import '../../core/dimensiones.dart';
import '../../core/formato.dart';
import '../../core/widgets/fila_dato.dart';
import 'datos_turno_confirmado.dart';

/// Pantalla de resumen despues de reservar un turno.
class TurnoConfirmadoScreen extends StatelessWidget {
  const TurnoConfirmadoScreen({super.key, required this.datos});

  final DatosTurnoConfirmado datos;

  @override
  Widget build(BuildContext context) {
    final paciente = datos.paciente;
    final turno = datos.turno;
    return Scaffold(
      appBar: AppBar(title: const Text('Clínica Vitalis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensiones.margenContenido),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle, size: Dimensiones.iconoDestacado),
            const SizedBox(height: Dimensiones.separacion),
            const Text(
              'Turno confirmado',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Dimensiones.textoTitulo,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Dimensiones.separacionChica),
            const Text(
              'El turno fue registrado correctamente.',
              textAlign: TextAlign.center,
            ),
            if (paciente != null) ...[
              const SizedBox(height: Dimensiones.separacionSeccion),
              _DatosPaciente(paciente: paciente),
            ],
            const SizedBox(height: Dimensiones.separacionExtra),
            const _TituloSeccion(texto: 'Datos del turno'),
            Card(
              child: Column(
                children: [
                  FilaDato(etiqueta: 'Especialidad', valor: turno.especialidad),
                  FilaDato(etiqueta: 'Profesional', valor: turno.profesional),
                  FilaDato(
                      etiqueta: 'Fecha', valor: formatearFecha(turno.fecha)),
                  FilaDato(etiqueta: 'Horario', valor: turno.horario),
                ],
              ),
            ),
            const SizedBox(height: Dimensiones.separacionExtra),
            OutlinedButton(
              onPressed: () =>
                  Navigator.popUntil(context, (ruta) => ruta.isFirst),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatosPaciente extends StatelessWidget {
  const _DatosPaciente({required this.paciente});

  final Paciente paciente;

  @override
  Widget build(BuildContext context) {
    final obraSocial = paciente.obraSocial ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TituloSeccion(texto: 'Datos del paciente'),
        Card(
          child: Column(
            children: [
              FilaDato(etiqueta: 'Nombre', valor: paciente.nombre),
              FilaDato(etiqueta: 'Apellido', valor: paciente.apellido),
              FilaDato(etiqueta: 'Correo', valor: paciente.correo),
              FilaDato(etiqueta: 'Teléfono', valor: paciente.telefono),
              if (obraSocial.isNotEmpty)
                FilaDato(etiqueta: 'Obra social', valor: obraSocial),
            ],
          ),
        ),
      ],
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensiones.separacionChica),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: Dimensiones.textoSubtitulo,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
