import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Programa y cancela los recordatorios de turnos.
class NotificacionesService {
  NotificacionesService._internal();

  static final NotificacionesService _instancia =
      NotificacionesService._internal();

  factory NotificacionesService() => _instancia;

  final FlutterLocalNotificationsPlugin _notificaciones =
      FlutterLocalNotificationsPlugin();

  /// Prepara zonas horarias, plugin y canal. NO pide permiso:
  /// el permiso se pide en contexto, con un botón (ver pedirPermiso).
  Future<void> inicializar() async {
    tz_data.initializeTimeZones();

    final zonaHoraria = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zonaHoraria.identifier));

    const configuracion = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _notificaciones.initialize(settings: configuracion);

    const canalRecordatorios = AndroidNotificationChannel(
      'recordatorios_turnos',
      'Recordatorios de turnos',
      description: 'Avisos de próximos turnos médicos.',
      importance: Importance.max,
    );

    await _notificaciones
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(canalRecordatorios);
  }

  /// Pide permiso para mostrar notificaciones (Android 13+).
  /// Devuelve true si el usuario lo otorgó.
  Future<bool> pedirPermiso() async {
    final android = _notificaciones.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    return await android.requestNotificationsPermission() ?? false;
  }

  /// Programa el aviso 24 h antes del turno.
  Future<void> programarRecordatorio(Turno turno) async {
    if (turno.id == null) return;
    if (turno.estado != EstadoTurno.confirmado) return;

    final fechaRecordatorio =
        turno.fechaHora.subtract(const Duration(hours: 24));
    if (!fechaRecordatorio.isAfter(DateTime.now())) return;

    const detalles = NotificationDetails(
      android: AndroidNotificationDetails(
        'recordatorios_turnos',
        'Recordatorios de turnos',
        channelDescription: 'Avisos de próximos turnos médicos.',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _notificaciones.zonedSchedule(
      id: turno.id!,
      title: 'Recordatorio de turno',
      body:
          'Mañana tenés turno con ${turno.profesional} a las ${turno.horario}.',
      scheduledDate: tz.TZDateTime.from(fechaRecordatorio, tz.local),
      notificationDetails: detalles,
      // Inexacta: es lo que recomienda el apunte para recordatorios
      // y no necesita el permiso especial de alarmas exactas.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Cancela el aviso con el mismo id del turno.
  Future<void> cancelarRecordatorio(int turnoId) async {
    await _notificaciones.cancel(id: turnoId);
  }
}
