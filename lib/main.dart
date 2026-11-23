import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/auth_repository_firebase.dart';
import 'data/repositories/borrador_repository_local.dart';
import 'data/repositories/conectividad_repository_plus.dart';
import 'data/repositories/historia_clinica_repository_simulado.dart';
import 'data/repositories/perfil_repository_firestore.dart';
import 'data/repositories/recordatorio_repository_local.dart';
import 'data/repositories/turno_repository_local.dart';
import 'data/services/auth_service.dart';
import 'data/services/base_datos_service.dart';
import 'data/services/conectividad_service.dart';
import 'data/services/historia_clinica_ejemplo_service.dart';
import 'data/services/notificaciones_service.dart';
import 'data/services/perfil_service.dart';
import 'data/services/preferencias_service.dart';
import 'data/services/profesionales_ejemplo_service.dart';
import 'domain/models/paciente.dart';
import 'domain/models/registro_clinico.dart';
import 'ui/auth/view_models/crear_cuenta_view_model.dart';
import 'ui/auth/view_models/login_view_model.dart';
import 'ui/auth/view_models/recuperar_contrasena_view_model.dart';
import 'ui/auth/view_models/sesion_view_model.dart';
import 'ui/auth/view_models/verificar_correo_view_model.dart';
import 'ui/auth/widgets/crear_cuenta_screen.dart';
import 'ui/auth/widgets/login_screen.dart';
import 'ui/auth/widgets/puerta_sesion.dart';
import 'ui/auth/widgets/recuperar_contrasena_screen.dart';
import 'ui/auth/widgets/verificar_correo_screen.dart';
import 'ui/conectividad/view_models/conectividad_view_model.dart';
import 'ui/core/bus_de_eventos.dart';
import 'ui/core/rutas.dart';
import 'ui/core/widgets/vitalis_app.dart';
import 'ui/historia_clinica/view_models/historia_clinica_view_model.dart';
import 'ui/historia_clinica/widgets/detalle_registro_screen.dart';
import 'ui/historia_clinica/widgets/historia_clinica_screen.dart';
import 'ui/inicio/view_models/inicio_view_model.dart';
import 'ui/inicio/widgets/inicio_screen.dart';
import 'ui/perfil/view_models/formulario_perfil_view_model.dart';
import 'ui/perfil/view_models/perfil_view_model.dart';
import 'ui/perfil/widgets/completar_perfil_screen.dart';
import 'ui/perfil/widgets/editar_perfil_screen.dart';
import 'ui/perfil/widgets/perfil_screen.dart';
import 'ui/sintomas/view_models/sintomas_view_model.dart';
import 'ui/sintomas/widgets/sintomas_screen.dart';
import 'ui/turnos/view_models/mis_turnos_view_model.dart';
import 'ui/turnos/view_models/solicitar_turno_view_model.dart';
import 'ui/turnos/widgets/datos_turno_confirmado.dart';
import 'ui/turnos/widgets/mis_turnos_screen.dart';
import 'ui/turnos/widgets/solicitar_turno_screen.dart';
import 'ui/turnos/widgets/turno_confirmado_screen.dart';

/// Punto de entrada y unico lugar donde se crean e inyectan las
/// dependencias: Service -> Repository -> ViewModel -> Screen.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Servicios.
  final authService = AuthService(
    auth: FirebaseAuth.instance,
    googleSignIn: GoogleSignIn(),
  );
  final perfilService = PerfilService(firestore: FirebaseFirestore.instance);
  final baseDatosService = BaseDatosService();
  final notificacionesService = NotificacionesService(
    plugin: FlutterLocalNotificationsPlugin(),
  );
  await notificacionesService.inicializar();
  final preferenciasService = PreferenciasService(
    preferencias: await SharedPreferences.getInstance(),
  );
  final conectividadService = ConectividadService(
    conectividad: Connectivity(),
  );

  // Repositorios.
  final authRepository = AuthRepositoryFirebase(authService: authService);
  final perfilRepository = PerfilRepositoryFirestore(
    perfilService: perfilService,
  );
  final turnoRepository = TurnoRepositoryLocal(
    baseDatosService: baseDatosService,
    profesionalesService: ProfesionalesEjemploService(),
  );
  final historiaClinicaRepository = HistoriaClinicaRepositorySimulado(
    historiaClinicaService: HistoriaClinicaEjemploService(),
  );
  final recordatorioRepository = RecordatorioRepositoryLocal(
    notificacionesService: notificacionesService,
  );
  final borradorRepository = BorradorRepositoryLocal(
    preferenciasService: preferenciasService,
  );
  final conectividadRepository = ConectividadRepositoryPlus(
    conectividadService: conectividadService,
  );

  final busDeEventos = BusDeEventos();

  // ViewModels.
  final sesionViewModel = SesionViewModel(
    authRepository: authRepository,
    perfilRepository: perfilRepository,
  );
  final loginViewModel = LoginViewModel(
    authRepository: authRepository,
    perfilRepository: perfilRepository,
  );
  final crearCuentaViewModel = CrearCuentaViewModel(
    authRepository: authRepository,
    perfilRepository: perfilRepository,
  );
  final recuperarContrasenaViewModel = RecuperarContrasenaViewModel(
    authRepository: authRepository,
  );
  final verificarCorreoViewModel = VerificarCorreoViewModel(
    authRepository: authRepository,
  );
  final formularioPerfilViewModel = FormularioPerfilViewModel(
    authRepository: authRepository,
    perfilRepository: perfilRepository,
  );
  final perfilViewModel = PerfilViewModel(
    authRepository: authRepository,
    perfilRepository: perfilRepository,
  );
  final inicioViewModel = InicioViewModel(
    authRepository: authRepository,
    perfilRepository: perfilRepository,
    busDeEventos: busDeEventos,
  );
  final conectividadViewModel = ConectividadViewModel(
    conectividadRepository: conectividadRepository,
  );
  final solicitarTurnoViewModel = SolicitarTurnoViewModel(
    turnoRepository: turnoRepository,
    borradorRepository: borradorRepository,
    recordatorioRepository: recordatorioRepository,
    authRepository: authRepository,
    perfilRepository: perfilRepository,
    busDeEventos: busDeEventos,
  );
  final misTurnosViewModel = MisTurnosViewModel(
    turnoRepository: turnoRepository,
    recordatorioRepository: recordatorioRepository,
    authRepository: authRepository,
    busDeEventos: busDeEventos,
  );
  final sintomasViewModel = SintomasViewModel(
    borradorRepository: borradorRepository,
    busDeEventos: busDeEventos,
  );
  final historiaClinicaViewModel = HistoriaClinicaViewModel(
    historiaClinicaRepository: historiaClinicaRepository,
    authRepository: authRepository,
  );

  // Pantallas.
  final puertaSesion = PuertaSesion(
    viewModel: sesionViewModel,
    pantallaLogin: LoginScreen(viewModel: loginViewModel),
    pantallaVerificarCorreo: VerificarCorreoScreen(
      viewModel: verificarCorreoViewModel,
      onVerificado: sesionViewModel.recargarSesion,
    ),
    pantallaCompletarPerfil: CompletarPerfilScreen(
      viewModel: formularioPerfilViewModel,
      onPerfilCompletado: sesionViewModel.recargarSesion,
    ),
    pantallaInicio: InicioScreen(
      viewModel: inicioViewModel,
      conectividadViewModel: conectividadViewModel,
      pantallaPerfil: PerfilScreen(viewModel: perfilViewModel),
    ),
  );

  Route<void>? generarRuta(RouteSettings ajustes) {
    final argumentos = ajustes.arguments;
    final Widget? pantalla = switch (ajustes.name) {
      Rutas.crearCuenta => CrearCuentaScreen(viewModel: crearCuentaViewModel),
      Rutas.recuperarContrasena => RecuperarContrasenaScreen(
          viewModel: recuperarContrasenaViewModel,
        ),
      Rutas.solicitarTurno =>
        SolicitarTurnoScreen(viewModel: solicitarTurnoViewModel),
      Rutas.turnoConfirmado when argumentos is DatosTurnoConfirmado =>
        TurnoConfirmadoScreen(datos: argumentos),
      Rutas.misTurnos => MisTurnosScreen(viewModel: misTurnosViewModel),
      Rutas.sintomas => SintomasScreen(viewModel: sintomasViewModel),
      Rutas.historiaClinica =>
        HistoriaClinicaScreen(viewModel: historiaClinicaViewModel),
      Rutas.detalleRegistro when argumentos is RegistroClinico =>
        DetalleRegistroScreen(registro: argumentos),
      Rutas.editarPerfil when argumentos is Paciente => EditarPerfilScreen(
          viewModel: formularioPerfilViewModel,
          paciente: argumentos,
        ),
      _ => null,
    };
    if (pantalla == null) return null;
    return MaterialPageRoute(builder: (_) => pantalla, settings: ajustes);
  }

  runApp(
    VitalisApp(pantallaInicial: puertaSesion, generarRuta: generarRuta),
  );
}
