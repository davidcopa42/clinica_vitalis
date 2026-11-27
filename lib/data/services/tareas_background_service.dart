import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

/// Nombre único de la tarea diaria que borra los turnos vencidos.
const tareaLimpiarTurnosVencidos = 'limpiar_turnos_vencidos';

/// Registra en WorkManager las tareas que la app ejecuta en background,
/// aunque esté cerrada.
class TareasBackgroundService {
  static const _frecuenciaLimpieza = Duration(days: 1);

  /// Inicializa WorkManager con [despachador] y programa la limpieza
  /// diaria de turnos vencidos.
  ///
  /// [despachador] es el punto de entrada del isolate de background: tiene
  /// que ser una función de nivel superior con `@pragma('vm:entry-point')`.
  ///
  /// Solo en Android: en iOS las tareas periódicas necesitan configurar
  /// BGTaskScheduler en Xcode, y el proyecto todavía no lo tiene.
  Future<void> inicializar(void Function() despachador) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    await Workmanager().initialize(despachador);
    await Workmanager().registerPeriodicTask(
      tareaLimpiarTurnosVencidos,
      tareaLimpiarTurnosVencidos,
      frequency: _frecuenciaLimpieza,
      // Si ya estaba programada no reinicia el contador de 24 horas en
      // cada apertura de la app.
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  /// Ejecuta cada tarea que WorkManager dispara con la acción de
  /// [tareas] que corresponde a su nombre.
  ///
  /// Se llama desde el despachador, ya dentro del isolate de background.
  /// Una acción que devuelve false o lanza hace que WorkManager la
  /// reintente más tarde.
  void atenderTareas(Map<String, Future<bool> Function()> tareas) {
    Workmanager().executeTask((nombreTarea, _) async {
      final tarea = tareas[nombreTarea];
      if (tarea == null) return true;
      try {
        return await tarea();
      } catch (_) {
        return false;
      }
    });
  }
}
