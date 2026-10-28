import 'package:flutter/material.dart';

import 'package:clinica_vitalis/data/services/datos_ejemplo.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/profesional.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:clinica_vitalis/ui/core/formato.dart';
import 'package:clinica_vitalis/ui/turnos/widgets/turno_confirmado.dart';

class TurnoPage extends StatefulWidget {
  const TurnoPage({
    super.key,
    required this.paciente,
  });

  final Paciente paciente;

  @override
  State<TurnoPage> createState() => _TurnoPageState();
}

class _TurnoPageState extends State<TurnoPage> {
  String? _especialidadSeleccionada;
  String? _profesionalSeleccionado;
  DateTime? _fechaSeleccionada;
  String? _horarioSeleccionado;

  /// Especialidades sin repetir, sacadas de los profesionales.
  List<String> get _especialidades => profesionalesDeEjemplo
      .map((profesional) => profesional.especialidad)
      .toSet()
      .toList();

  /// Profesionales de la especialidad elegida.
  List<Profesional> get _profesionalesDisponibles => profesionalesDeEjemplo
      .where((profesional) =>
  profesional.especialidad == _especialidadSeleccionada)
      .toList();

  /// Horarios del profesional elegido.
  List<String> get _horariosDisponibles {
    for (final profesional in profesionalesDeEjemplo) {
      if (profesional.nombre == _profesionalSeleccionado) {
        return profesional.horarios;
      }
    }
    return [];
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 90),
      ),
      initialDate: _fechaSeleccionada ?? DateTime.now(),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
        _horarioSeleccionado = null;
      });
    }
  }

  void _seleccionarEspecialidad(String? valor) {
    setState(() {
      _especialidadSeleccionada = valor;
      _profesionalSeleccionado = null;
      _horarioSeleccionado = null;
    });
  }

  void _seleccionarProfesional(String? valor) {
    setState(() {
      _profesionalSeleccionado = valor;
      _horarioSeleccionado = null;
    });
  }

  void _confirmarTurno() {
    if (_especialidadSeleccionada == null ||
        _profesionalSeleccionado == null ||
        _fechaSeleccionada == null ||
        _horarioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completá todos los datos del turno.',
          ),
        ),
      );

      return;
    }

    final turno = Turno(
      // TODO: reemplazar por widget.paciente.uid cuando esté el login.
      pacienteUid: widget.paciente.correo,
      especialidad: _especialidadSeleccionada!,
      profesional: _profesionalSeleccionado!,
      fecha: _fechaSeleccionada!,
      horario: _horarioSeleccionado!,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TurnoConfirmadoPage(
          paciente: widget.paciente,
          turno: turno,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final puedeElegirHorario =
        _profesionalSeleccionado != null && _fechaSeleccionada != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clínica Vitalis',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Solicitar turno',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            DropdownButtonFormField<String>(
              value: _especialidadSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Especialidad',
                border: OutlineInputBorder(),
              ),
              items: _especialidades.map((especialidad) {
                return DropdownMenuItem(
                  value: especialidad,
                  child: Text(especialidad),
                );
              }).toList(),
              onChanged: _seleccionarEspecialidad,
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _profesionalSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Profesional',
                border: OutlineInputBorder(),
              ),
              items: _profesionalesDisponibles.map((profesional) {
                return DropdownMenuItem(
                  value: profesional.nombre,
                  child: Text(profesional.nombre),
                );
              }).toList(),
              onChanged: _especialidadSeleccionada == null
                  ? null
                  : _seleccionarProfesional,
            ),

            const SizedBox(height: 20),

            const Text(
              'Fecha',
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _seleccionarFecha,
                icon: const Icon(
                  Icons.calendar_month,
                ),
                label: Text(
                  _fechaSeleccionada == null
                      ? 'Seleccionar fecha'
                      : formatearFecha(_fechaSeleccionada!),
                ),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _horarioSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Horario',
                border: OutlineInputBorder(),
              ),
              items: _horariosDisponibles.map((horario) {
                return DropdownMenuItem(
                  value: horario,
                  child: Text(horario),
                );
              }).toList(),
              onChanged: puedeElegirHorario
                  ? (valor) {
                setState(() {
                  _horarioSeleccionado = valor;
                });
              }
                  : null,
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmarTurno,
                child: const Text(
                  'Confirmar turno',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}