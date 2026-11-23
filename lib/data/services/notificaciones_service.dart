import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Acceso directo al plugin de notificaciones locales.
class NotificacionesService {
  NotificacionesService({required FlutterLocalNotificationsPlugin plugin})
      : _plugin = plugin;

  static const idCanal = 'recordatorios_turnos';
  static const nombreCanal = 'Recordatorios de turnos';
  static const descripcionCanal = 'Avisos de proximos turnos medicos.';
  static const iconoAndroid = '@mipmap/ic_launcher';

  final FlutterLocalNotificationsPlugin _plugin;

  /// Configura zona horaria, canal de Android y permisos.
  Future<void> inicializar() async {
    tz_data.initializeTimeZones();
    final zonaHoraria = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zonaHoraria.identifier));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(iconoAndroid),
      ),
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        idCanal,
        nombreCanal,
        description: descripcionCanal,
        importance: Importance.max,
      ),
    );
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  /// Programa una notificacion para [fecha] en la zona horaria local.
  Future<void> programar({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fecha,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: titulo,
      body: cuerpo,
      scheduledDate: tz.TZDateTime.from(fecha, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          idCanal,
          nombreCanal,
          channelDescription: descripcionCanal,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancela la notificacion con ese [id].
  Future<void> cancelar(int id) async {
    await _plugin.cancel(id: id);
  }
}
