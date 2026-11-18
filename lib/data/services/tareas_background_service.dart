import 'package:clinica_vitalis/data/repositories/turno_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

/// Nombre único de la tarea periódica. Sirve para que Android no la
/// registre dos veces cada vez que se abre la app.
const String tareaLimpiarTurnosVencidos = 'limpiar_turnos_vencidos';

/// Punto de entrada de las tareas en background.
///
/// Android lo ejecuta en un isolate aparte, aunque la app esté cerrada.
/// Tiene que ser una función de nivel superior y llevar el `@pragma`
/// para que el compilador no la elimine al generar el APK de release.
@pragma('vm:entry-point')
void despacharTareas() {
  Workmanager().executeTask((nombreTarea, datos) async {
    switch (nombreTarea) {
      case tareaLimpiarTurnosVencidos:
        try {
          final borrados = await TurnoRepository().limpiarTurnosVencidos();
          debugPrint(
              'Tarea en background: $borrados turnos vencidos borrados.');
          return true;
        } catch (error) {
          debugPrint('Tarea en background falló: $error');
          // false hace que WorkManager vuelva a intentarlo más tarde.
          return false;
        }
      default:
        return true;
    }
  });
}

/// Registra las tareas que la app ejecuta en background con WorkManager.
class TareasBackgroundService {
  /// Inicializa WorkManager y programa la limpieza diaria de turnos vencidos.
  ///
  /// Solo en Android: en iOS las tareas periódicas necesitan configuración
  /// extra en Xcode (BGTaskScheduler) que el proyecto todavía no tiene.
  Future<void> inicializar() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    await Workmanager().initialize(despacharTareas);
    await Workmanager().registerPeriodicTask(
      tareaLimpiarTurnosVencidos,
      tareaLimpiarTurnosVencidos,
      frequency: const Duration(days: 1),
      // Si ya estaba programada, la deja como está en lugar de reiniciar
      // el contador de 24 horas en cada apertura de la app.
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}
