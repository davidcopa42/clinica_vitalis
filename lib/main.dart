import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'data/repositories/auth_repositorio_firebase.dart';
import 'data/repositories/borrador_repositorio_local.dart';
import 'data/repositories/conectividad_repositorio_local.dart';
import 'data/repositories/historia_clinica_repositorio_simulado.dart';
import 'data/repositories/perfil_repositorio_firestore.dart';
import 'data/repositories/recordatorio_repositorio_local.dart';
import 'data/repositories/turno_repositorio_local.dart';
import 'data/services/auth_service.dart';
import 'data/services/base_datos_service.dart';
import 'data/services/borrador_service.dart';
import 'data/services/bus_de_eventos.dart';
import 'data/services/conectividad_service.dart';
import 'data/services/notificaciones_service.dart';
import 'data/services/perfil_service.dart';
import 'data/services/tareas_background_service.dart';
import 'dependencias.dart';
import 'ui/auth/view_models/sesion_view_model.dart';
import 'ui/auth/widgets/puerta_sesion.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Servicios: hablan con el exterior.
  final notificacionesService = NotificacionesService();
  await notificacionesService.inicializar();

  try {
    await TareasBackgroundService().inicializar(despacharTareas);
  } catch (_) {
    // La limpieza de turnos vencidos no es imprescindible: si WorkManager
    // falla, la app abre igual.
  }

  // Repositorios: reciben sus servicios por constructor.
  final dependencias = Dependencias(
    authRepository: AuthRepositorioFirebase(authService: AuthService()),
    perfilRepository:
        PerfilRepositorioFirestore(perfilService: PerfilService()),
    turnoRepository: TurnoRepositorioLocal(baseDatos: BaseDatosService()),
    historiaClinicaRepository: HistoriaClinicaRepositorioSimulado(),
    borradorRepository:
        BorradorRepositorioLocal(borradorService: BorradorService()),
    recordatorioRepository: RecordatorioRepositorioLocal(
      notificacionesService: notificacionesService,
    ),
    conectividadRepository: ConectividadRepositorioLocal(
      conectividadService: ConectividadConPlus(),
    ),
    busDeEventos: BusDeEventos(),
  );

  // ViewModel que vive mientras vive la app.
  final sesionViewModel = SesionViewModel(
    authRepo: dependencias.authRepository,
    perfilRepo: dependencias.perfilRepository,
  );

  runApp(
    ClinicaVitalisApp(
        sesionViewModel: sesionViewModel, dependencias: dependencias),
  );
}

/// Punto de entrada de las tareas en background.
///
/// Android lo ejecuta en otro isolate, aunque la app esté cerrada, así que
/// no comparte las instancias de [main]: arma acá las que necesita.
/// El `@pragma` evita que el compilador lo elimine en el APK de release.
@pragma('vm:entry-point')
void despacharTareas() {
  final turnoRepository = TurnoRepositorioLocal(baseDatos: BaseDatosService());

  TareasBackgroundService().atenderTareas({
    tareaLimpiarTurnosVencidos: () async {
      await turnoRepository.limpiarTurnosVencidos();
      return true;
    },
  });
}

class ClinicaVitalisApp extends StatelessWidget {
  const ClinicaVitalisApp({
    super.key,
    required this.sesionViewModel,
    required this.dependencias,
  });

  final SesionViewModel sesionViewModel;
  final Dependencias dependencias;

  @override
  Widget build(BuildContext context) {
    const Color semilla = Colors.blue;
    return MaterialApp(
      title: 'Clínica Vitalis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: semilla,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: semilla,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: PuertaSesion(
        sesionViewModel: sesionViewModel,
        dependencias: dependencias,
      ),
    );
  }
}
