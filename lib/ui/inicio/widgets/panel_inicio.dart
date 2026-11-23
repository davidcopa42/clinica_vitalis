import 'package:flutter/material.dart';

import '../../conectividad/view_models/conectividad_view_model.dart';
import '../../conectividad/widgets/aviso_sin_conexion.dart';
import '../../core/dimensiones.dart';
import '../../core/rutas.dart';
import '../../core/widgets/avatar_paciente.dart';
import '../view_models/inicio_view_model.dart';
import '../view_models/pestania_inicio.dart';
import 'opcion_inicio_card.dart';

/// Contenido de la pestania Inicio: saludo y accesos a cada funcionalidad.
class PanelInicio extends StatelessWidget {
  const PanelInicio({
    super.key,
    required this.viewModel,
    required this.conectividadViewModel,
  });

  static const rutaLogo = 'assets/images/logo_vitalis.png';
  static const radioAvatar = 18.0;

  final InicioViewModel viewModel;
  final ConectividadViewModel conectividadViewModel;

  @override
  Widget build(BuildContext context) {
    void abrir(String ruta) => Navigator.pushNamed(context, ruta);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(Dimensiones.separacionChica),
          child: Image.asset(rutaLogo, fit: BoxFit.contain),
        ),
        title: const Text('Clínica Vitalis'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Dimensiones.separacion),
            child: GestureDetector(
              onTap: () => viewModel.seleccionarPestania(PestaniaInicio.perfil),
              child: AvatarPaciente(
                fotoUrl: viewModel.fotoUrl,
                radio: radioAvatar,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          AvisoSinConexion(viewModel: conectividadViewModel),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(Dimensiones.margenContenido),
              children: [
                const Icon(
                  Icons.local_hospital,
                  size: Dimensiones.iconoDestacado,
                  color: Colors.blue,
                ),
                const SizedBox(height: Dimensiones.separacionMedia),
                Text(
                  viewModel.saludo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: Dimensiones.textoTitulo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Dimensiones.separacionSeccion),
                OpcionInicioCard(
                  icono: Icons.calendar_month,
                  titulo: 'Solicitar un turno',
                  descripcion: 'Elegí una especialidad, profesional y horario.',
                  onTap: () => abrir(Rutas.solicitarTurno),
                ),
                OpcionInicioCard(
                  icono: Icons.event_available,
                  titulo: 'Mis turnos',
                  descripcion: 'Consultá y cancelá tus turnos.',
                  onTap: () => abrir(Rutas.misTurnos),
                ),
                OpcionInicioCard(
                  icono: Icons.medical_information,
                  titulo: 'Registrar síntomas',
                  descripcion:
                      'Contanos cómo te sentís y recibí una recomendación.',
                  onTap: () => abrir(Rutas.sintomas),
                ),
                OpcionInicioCard(
                  icono: Icons.description,
                  titulo: 'Historia clínica',
                  descripcion: 'Consultá tu información clínica.',
                  onTap: () => abrir(Rutas.historiaClinica),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
