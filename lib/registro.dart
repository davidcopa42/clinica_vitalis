import 'package:flutter/material.dart';

import 'paciente.dart';
import 'solicitar_turno.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final TextEditingController _nombreController =
  TextEditingController();

  final TextEditingController _apellidoController =
  TextEditingController();

  final TextEditingController _correoController =
  TextEditingController();

  final TextEditingController _telefonoController =
  TextEditingController();

  final TextEditingController _codigoController =
  TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _codigoController.dispose();

    super.dispose();
  }

  void _confirmarRegistro() {
    if (_nombreController.text.isEmpty ||
        _apellidoController.text.isEmpty ||
        _correoController.text.isEmpty ||
        _telefonoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completá todos los campos.',
          ),
        ),
      );

      return;
    }

    final paciente = Paciente(
      nombre: _nombreController.text,
      apellido: _apellidoController.text,
      correo: _correoController.text,
      telefono: _telefonoController.text,
    );

    _mostrarVerificacion(paciente);
  }

  void _mostrarVerificacion(Paciente paciente) {
    _codigoController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Verificar correo',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Se envió un código a tu correo electrónico.',
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _codigoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Código',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancelar',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                if (_codigoController.text == '1234') {
                  Navigator.pop(dialogContext);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TurnoPage(
                        paciente: paciente,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'El código ingresado es incorrecto.',
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'Verificar',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              'Datos personales',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Para solicitar un turno completá tus datos personales.',
            ),

            const SizedBox(height: 25),

            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _apellidoController,
              decoration: const InputDecoration(
                labelText: 'Apellido',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmarRegistro,
                child: const Text(
                  'Confirmar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}