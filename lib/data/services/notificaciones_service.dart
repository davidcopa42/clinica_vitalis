
import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificacionesService {
  NotificacionesService._internal();

  static final NotificacionesService _instancia =
  NotificacionesService._internal();

  factory NotificacionesService() => _instancia;

  final FlutterLocalNotificationsPlugin _notificaciones =
  FlutterLocalNotificationsPlugin();

  Future<void> inicializar() async {
    tz_data.initializeTimeZones();

    final zonaHoraria = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zonaHoraria.identifier));

    const configuracionAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const configuracion = InitializationSettings(
      android: configuracionAndroid,
    );

    await _notificaciones.initialize(
      settings: configuracion,
    );

    final android = _notificaciones.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Crear explícitamente el canal de notificaciones.
    const canalRecordatorios = AndroidNotificationChannel(
      'recordatorios_turnos',
      'Recordatorios de turnos',
      description: 'Avisos de próximos turnos médicos.',
      importance: Importance.max,
    );

    await android?.createNotificationChannel(canalRecordatorios);

    // Solicitar permisos.
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  Future<void> programarRecordatorio(Turno turno) async {
    if (turno.id == null) return;

    if (turno.estado != EstadoTurno.confirmado) return;

    final fechaRecordatorio =
    turno.fechaHora.subtract(const Duration(hours: 24));

    if (!fechaRecordatorio.isAfter(DateTime.now())) return;

    final fechaProgramada =
    tz.TZDateTime.from(fechaRecordatorio, tz.local);

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
      scheduledDate: fechaProgramada,
      notificationDetails: detalles,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelarRecordatorio(int turnoId) async {
    await _notificaciones.cancel(id: turnoId);
  }
}
