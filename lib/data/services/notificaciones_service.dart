import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificacionesService {
  static const _idCanal = 'recordatorios_turnos';
  static const _nombreCanal = 'Recordatorios de turnos';
  static const _descripcionCanal = 'Avisos de próximos turnos médicos.';

  /// Cuánto antes del turno llega el recordatorio.
  static const _anticipacionRecordatorio = Duration(hours: 24);

  NotificacionesService._internal();

  static final NotificacionesService _instancia =
      NotificacionesService._internal();

  factory NotificacionesService() => _instancia;

  final FlutterLocalNotificationsPlugin _notificaciones =
      FlutterLocalNotificationsPlugin();

  /// Prepara zonas horarias, plugin y canal.
  ///
  /// No pide permiso: se pide en contexto, con un botón ([pedirPermiso]).
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

    const canalRecordatorios = AndroidNotificationChannel(
      _idCanal,
      _nombreCanal,
      description: _descripcionCanal,
      importance: Importance.max,
    );

    await android?.createNotificationChannel(canalRecordatorios);
  }

  /// Pide permiso para mostrar notificaciones (Android 13 o posterior).
  ///
  /// Devuelve true si el usuario lo otorgó.
  Future<bool> pedirPermiso() async {
    final android = _notificaciones.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    return await android.requestNotificationsPermission() ?? false;
  }

  Future<void> programarRecordatorio(Turno turno) async {
    if (turno.id == null) return;

    if (turno.estado != EstadoTurno.confirmado) return;

    final fechaRecordatorio =
        turno.fechaHora.subtract(_anticipacionRecordatorio);

    if (!fechaRecordatorio.isAfter(DateTime.now())) return;

    final fechaProgramada = tz.TZDateTime.from(fechaRecordatorio, tz.local);

    const detalles = NotificationDetails(
      android: AndroidNotificationDetails(
        _idCanal,
        _nombreCanal,
        channelDescription: _descripcionCanal,
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
      // Inexacta: alcanza para un recordatorio y no necesita el permiso
      // especial de alarmas exactas.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelarRecordatorio(int turnoId) async {
    await _notificaciones.cancel(id: turnoId);
  }
}
