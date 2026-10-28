import 'package:flutter/material.dart';

import '../../../domain/models/paciente.dart';
import '../../../domain/models/turno.dart';
import 'turno_confirmado.dart';
import 'package:clinica_vitalis/ui/core/formato.dart';
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
  final List<String> _especialidades = [
    'Clínica Médica',
    'Cardiología',
    'Pediatría',
    'Dermatología',
  ];

  final Map<String, List<String>> _profesionales = {
    'Clínica Médica': [
      'Dra. Ana López',
      'Dr. Roberto Díaz',
    ],
    'Cardiología': [
      'Dr. Juan Pérez',
    ],
    'Pediatría': [
      'Dra. María Gómez',
    ],
    'Dermatología': [
      'Dr. Carlos Ruiz',
    ],
  };

  final List<String> _horarios = [
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
  ];

  String? _especialidadSeleccionada;
  String? _profesionalSeleccionado;
  DateTime? _fechaSeleccionada;
  String? _horarioSeleccionado;

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 90),
      ),
      initialDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  void _seleccionarEspecialidad(String? valor) {
    setState(() {
      _especialidadSeleccionada = valor;
      _profesionalSeleccionado = null;
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

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final profesionalesDisponibles =
    _especialidadSeleccionada == null
        ? <String>[]
        : _profesionales[_especialidadSeleccionada] ?? [];

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
              items: profesionalesDisponibles.map((profesional) {
                return DropdownMenuItem(
                  value: profesional,
                  child: Text(profesional),
                );
              }).toList(),
              onChanged: _especialidadSeleccionada == null
                  ? null
                  : (valor) {
                setState(() {
                  _profesionalSeleccionado = valor;
                });
              },
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
                      : formatearFecha(
                    _fechaSeleccionada!,
                  ),
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
              items: _horarios.map((horario) {
                return DropdownMenuItem(
                  value: horario,
                  child: Text(horario),
                );
              }).toList(),
              onChanged: _fechaSeleccionada == null
                  ? null
                  : (valor) {
                setState(() {
                  _horarioSeleccionado = valor;
                });
              },
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