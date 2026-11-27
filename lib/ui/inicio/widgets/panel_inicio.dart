import 'package:flutter/material.dart';

import '../../conectividad/view_models/conectividad_view_model.dart';
import '../../conectividad/widgets/aviso_sin_conexion.dart';
import 'avatar_usuario.dart';
import 'tarjeta_accion.dart';

/// Pestaña Inicio: saludo, aviso de conexión y accesos a cada sección.
class PanelInicio extends StatelessWidget {
  const PanelInicio({
    super.key,
    required this.saludo,
    required this.fotoUrl,
    required this.conectividadViewModel,
    required this.alTocarAvatar,
    required this.alSolicitarTurno,
    required this.alAbrirMisTurnos,
    required this.alRegistrarSintomas,
    required this.alAbrirHistoriaClinica,
  });

  final String saludo;
  final String? fotoUrl;
  final ConectividadViewModel conectividadViewModel;
  final VoidCallback alTocarAvatar;
  final VoidCallback alSolicitarTurno;
  final VoidCallback alAbrirMisTurnos;
  final VoidCallback alRegistrarSintomas;
  final VoidCallback alAbrirHistoriaClinica;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo_vitalis.png',
            fit: BoxFit.contain,
          ),
        ),
        title: const Text('Clínica Vitalis'),
        centerTitle: true,
        actions: [
          AvatarUsuario(fotoUrl: fotoUrl, alTocar: alTocarAvatar),
        ],
      ),
      body: Column(
        children: [
          AvisoSinConexion(viewModel: conectividadViewModel),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  const Icon(
                    Icons.local_hospital,
                    size: 70,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    saludo,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 35),
                  TarjetaAccion(
                    icono: Icons.calendar_month,
                    titulo: 'Solicitar un turno',
                    descripcion:
                        'Elegí una especialidad, profesional y horario.',
                    alTocar: alSolicitarTurno,
                  ),
                  const SizedBox(height: 12),
                  TarjetaAccion(
                    icono: Icons.event_available,
                    titulo: 'Mis turnos',
                    descripcion: 'Consultá y cancelá tus turnos.',
                    alTocar: alAbrirMisTurnos,
                  ),
                  const SizedBox(height: 12),
                  TarjetaAccion(
                    icono: Icons.medical_information,
                    titulo: 'Registrar síntomas',
                    descripcion:
                        'Contanos cómo te sentís y recibí una recomendación.',
                    alTocar: alRegistrarSintomas,
                  ),
                  const SizedBox(height: 12),
                  TarjetaAccion(
                    icono: Icons.description,
                    titulo: 'Historia clínica',
                    descripcion: 'Consultá tu información clínica.',
                    alTocar: alAbrirHistoriaClinica,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
