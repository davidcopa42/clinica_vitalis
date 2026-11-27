# Clínica Vitalis

Aplicación móvil desarrollada en Flutter para la gestión de turnos y servicios de una clínica. Permite a los pacientes crear una cuenta, solicitar y cancelar turnos con profesionales de distintas especialidades, registrar sus síntomas y consultar su historia clínica desde el celular. El backend es Firebase (Auth y Firestore) más una base SQLite local.

## Módulos

### Autenticación
- Registro e inicio de sesión con correo y contraseña, o con una cuenta de Google, mediante **Firebase Authentication**.
- Verificación del correo electrónico y recuperación de contraseña.
- Al ingresar por primera vez, el paciente completa su perfil (nombre, apellido, teléfono, obra social), que se guarda en **Cloud Firestore**.
- `PuertaSesion` decide qué pantalla mostrar según el estado de la sesión (login, verificar correo, completar perfil o inicio).
- Código: `lib/ui/auth/`, `lib/data/repositories/auth_repository.dart`, `lib/data/services/auth_service.dart`.

### Turnos
- El paciente elige especialidad, profesional, fecha y horario, y la app muestra solo los horarios disponibles.
- La pantalla **Solicitar turno** se adapta al ancho disponible con `LayoutBuilder` (en `FormularioTurno`):
  - En celulares (600 px o menos) muestra el formulario en una sola columna.
  - En pantallas anchas, como tablets (más de 600 px), lo muestra en dos columnas: **¿Con quién?** (especialidad y profesional) y **¿Cuándo?** (fecha y horario). El botón de confirmar queda abajo, ocupando todo el ancho.
  - El formulario tiene un ancho máximo de 900 px y queda centrado, para que los campos no se estiren en pantallas muy grandes.
- Al confirmar, se muestra la pantalla **Turno confirmado** con los datos del paciente y del turno (con una animación de aparición `FadeTransition`).
- Desde esa pantalla se puede activar un recordatorio: una notificación local un día antes del turno (ver [Notificaciones](#notificaciones-de-recordatorio)).
- En **Mis turnos** se listan los turnos solicitados y se pueden cancelar. La lista se filtra y ordena en un isolate aparte con `compute()`, para no trabar la interfaz.
- Una tarea en background borra los turnos vencidos una vez por día (ver [Tareas en background](#tareas-en-background-workmanager)).
- Los turnos se guardan localmente con **SQLite** (`sqflite`).
- Código: `lib/ui/turnos/`, `lib/data/repositories/turno_repositorio_local.dart`, `lib/data/services/base_datos_service.dart`.

### Síntomas
- El paciente selecciona sus síntomas de una lista, indica la duración y la intensidad (escala 1 a 10) y puede agregar una descripción.
- Si marca síntomas de alarma (dolor de pecho, falta de aire, pérdida de conocimiento, etc.) o una intensidad muy alta, la app lo advierte y sugiere buscar atención urgente.
- El formulario se guarda como borrador en el dispositivo con cada cambio, para no perder lo cargado al salir de la pantalla o cerrar la app. Al volver a la app, el borrador se vuelve a cargar, y al registrar los síntomas se borra.
- El borrador lo maneja `BorradorRepository` (`obtenerBorradorSintomas()`, `guardarBorradorSintomas()` y `borrarBorradorSintomas()`), que lo guarda con `shared_preferences` mediante `BorradorService`. El `SintomasViewModel` solo usa el repositorio y no conoce cómo se almacena. Los datos viajan en el modelo `BorradorSintomas`. El mismo repositorio guarda el borrador de Solicitar turno.
- Desde el registro de síntomas se puede ir directamente a solicitar un turno.
- Código: `lib/ui/sintomas/`, `lib/data/repositories/borrador_repositorio_local.dart`, `lib/domain/models/borrador_sintomas.dart`.

### Historia clínica
- Muestra los registros clínicos del paciente (análisis, estudios y recetas), con filtros por tipo.
- Cada registro abre una pantalla de detalle.
- Maneja los estados de carga, error (con botón "Reintentar") y lista vacía.
- Por ahora los registros son datos de ejemplo.
- Código: `lib/ui/historia_clinica/`, `lib/data/repositories/historia_clinica_repositorio_simulado.dart`.

### Notificaciones de recordatorio
- Se programan con `flutter_local_notifications` para 24 horas antes del turno, en el canal **Recordatorios de turnos**. Se usa una alarma inexacta (`inexactAllowWhileIdle`), así que no hace falta el permiso de alarmas exactas.
- El permiso de notificaciones (Android 13 o superior) se pide en contexto, con el botón **Avisarme un día antes** de la pantalla Turno confirmado. Si el usuario lo niega, la app sigue funcionando.
- Al cancelar un turno, también se cancela su recordatorio.
- **Al tocar la notificación, la app abre directamente Mis turnos.** Cada recordatorio lleva el payload `mis_turnos`:
  - Con la app abierta o en segundo plano, el toque llega por `onDidReceiveNotificationResponse` y `NotificacionesService` lo emite en el stream `toques`.
  - Con la app cerrada, ese callback no se ejecuta, así que se consulta `getNotificationAppLaunchDetails()`.
  - En los dos casos `RecordatorioRepository` recuerda el toque hasta que alguien lo atiende, `InicioViewModel` lo expone como `debeAbrirMisTurnos` e `InicioScreen` abre Mis turnos cuando la sesión ya está lista. Si la notificación se toca antes de iniciar sesión, Mis turnos se abre después del login.
- Código: `lib/data/services/notificaciones_service.dart`, `lib/data/repositories/recordatorio_repositorio_local.dart`, `lib/ui/inicio/`.

### Tareas en background (WorkManager)
- Con el paquete `workmanager` se registra una tarea periódica, `limpiar_turnos_vencidos`, que Android ejecuta **una vez por día**, aunque la app esté cerrada.
- La tarea borra de la base local los turnos cuya fecha y hora ya pasaron, estén confirmados o cancelados (`TurnoRepository.limpiarTurnosVencidos()`). Si falla, WorkManager la reintenta más tarde.
- Se registra al abrir la app con la política `keep`, así que volver a abrirla no reinicia el contador de 24 horas.
- Android decide el momento exacto según la batería y el uso del dispositivo, así que no corre siempre a la misma hora.
- Por ahora solo funciona en **Android**. En iOS, las tareas periódicas necesitan configurar BGTaskScheduler en Xcode.
- Código: `lib/data/services/tareas_background_service.dart` y el punto de entrada `despacharTareas` en `lib/main.dart`.

### Otros
- **Perfil y ajustes**: ver y editar los datos del paciente (`lib/ui/perfil/`).
- **Conectividad**: aviso cuando el dispositivo se queda sin conexión a internet (`lib/ui/conectividad/`).

## Arquitectura

La app sigue MVVM en capas. Las dependencias van en un solo sentido:

```
View  ->  ViewModel  ->  Repository  ->  Service
```

| Capa | Carpeta | Responsabilidad |
|---|---|---|
| View | `lib/ui/<funcionalidad>/widgets/` | Pantallas (`<Funcionalidad>Screen`) y componentes. Reciben su ViewModel por constructor y se redibujan con `ListenableBuilder`. No contienen lógica de negocio. |
| ViewModel | `lib/ui/<funcionalidad>/view_models/` | `<Funcionalidad>ViewModel extends ChangeNotifier`. Guardan el estado de la pantalla y lo exponen con getters inmutables y el enum `EstadoCarga`. Solo importan `foundation.dart`: nada de `material.dart` ni `BuildContext`. |
| Repository | `lib/data/repositories/` | Fuente de verdad de cada entidad. Un contrato `abstract class <Entidad>Repository` y una implementación que recibe su Service por constructor. Convierten datos crudos en modelos y traducen los errores. |
| Service | `lib/data/services/` | Acceso directo a sistemas externos: Firebase Auth, Firestore, SQLite, SharedPreferences, notificaciones y conectividad. No guardan estado. |
| Modelos | `lib/domain/models/` | Clases Dart puras (`Paciente`, `Turno`, `Profesional`, `RegistroClinico`...) con `fromMap`/`toMap`/`copyWith`. No importan Flutter. |

Otras piezas:

- **`lib/main.dart`** es el único lugar donde se crean las dependencias, de
  abajo hacia arriba: Services, luego Repositories, luego `Dependencias`
  (`lib/dependencias.dart`, que agrupa los contratos) y `SesionViewModel`.
- **`PuertaSesion`** decide qué pantalla mostrar según el `EstadoSesion`
  (`sinSesion`, `correoSinVerificar`, `perfilIncompleto` o `lista`) y crea y
  descarta los ViewModels de cada estado.
- **Pantallas secundarias**: quien navega crea el ViewModel justo antes de
  `Navigator.push`; la pantalla lo recibe y lo descarta al cerrarse.
- **`BusDeEventos`** comunica módulos sin acoplarlos: `TurnoViewModel`
  publica `TurnoConfirmadoEvento` y `MisTurnosViewModel` e `InicioViewModel`
  reaccionan.
- **`lib/ui/core/`** reúne lo compartido por la interfaz: `EstadoCarga`,
  `MensajeError`, `DialogoCerrarSesion`, formatos de fecha y duraciones.
- **Tareas en background**: WorkManager las ejecuta en otro isolate, que no
  comparte las instancias de la app. Su punto de entrada, `despacharTareas`,
  también vive en `main.dart` y arma ahí los repositorios que necesita.

## Cómo correr el proyecto

### Requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `>=3.3.0`).
- Android Studio con un emulador Android, o un dispositivo físico con la depuración USB activada.
- JDK 17.

### Pasos
1. Clonar el repositorio:
   ```bash
   git clone https://github.com/davidcopa42/clinica_vitalis.git
   cd clinica_vitalis
   ```
2. Instalar las dependencias:
   ```bash
   flutter pub get
   ```
3. Verificar que Flutter detecte el emulador o el dispositivo:
   ```bash
   flutter devices
   ```
4. Ejecutar la aplicación:
   ```bash
   flutter run
   ```

La configuración de Firebase ya está incluida (`android/app/google-services.json` y `lib/firebase_options.dart`), por lo que no hace falta configurarlo para correr la app.

### Comandos

```bash
flutter pub get          # instala las dependencias
flutter run              # ejecuta la app

dart format .            # formatea el código (ancho de línea 80)
flutter analyze          # análisis estático y lints
flutter test             # corre todos los tests

flutter test test/turnos/mis_turnos_view_model_test.dart   # un archivo
flutter test --plain-name "nombre del test"                # un test por nombre

dart run flutter_launcher_icons   # regenera los íconos de la app
```

Antes de entregar, `dart format .`, `flutter analyze` y `flutter test` deben
terminar sin cambios, sin problemas y con todos los tests en verde.

## Tests

`test/` refleja la estructura de `lib/`:

- **ViewModels** (`test/<funcionalidad>/*_view_model_test.dart`): se prueban
  con repositorios falsos.
- **Pantallas** (`*_screen_test.dart`): widget tests que montan la pantalla
  con su ViewModel y verifican lo que ve y hace el usuario.
- **Repositorios y modelos** (`test/data/`, `test/domain/`).

Los repositorios falsos están escritos a mano e implementan el contrato
abstracto (`implements <Entidad>Repository`); no se usa ninguna librería de
mocks. Los compartidos están en `test/fakes/`.

## Convenciones

### 1. Idioma y nomenclatura
- Utilizaremos el español para los nombres de clases, variables, métodos y componentes, manteniendo los términos técnicos propios de Flutter cuando corresponda.
- Los archivos Dart se nombrarán en `snake_case`, por ejemplo: `solicitar_turno_screen.dart` y `historia_clinica_view_model.dart`.
- Las clases utilizarán `PascalCase`, por ejemplo: `Paciente`, `Profesional`, `Turno` y `HistoriaClinica`.
- Las variables y los métodos utilizarán `camelCase`, por ejemplo: `nombrePaciente`, `fechaTurno` y `obtenerTurnosDisponibles()`.
- Los nombres deberán ser descriptivos y representar claramente la información o responsabilidad correspondiente.

### 2. Organización de pantallas y componentes
- Las pantallas principales utilizarán nombres relacionados con la funcionalidad que representan, por ejemplo: `InicioScreen`, `SolicitarTurnoScreen`, `HistoriaClinicaScreen` y `TurnoConfirmadoScreen`.
- Los componentes reutilizables tendrán nombres que describan su función, por ejemplo: `TarjetaRegistro`, `FormularioTurno` y `MensajeError`.
- Los modelos representarán las entidades principales del sistema, como pacientes, profesionales, turnos y registros de historia clínica.
- La lógica de acceso a datos y las operaciones del sistema se mantienen separadas de los componentes visuales, según las capas descritas en [Arquitectura](#arquitectura).
- Se mantendrá una organización coherente de archivos y carpetas para facilitar el mantenimiento y la incorporación de nuevas funcionalidades.

### 3. Verbos para las acciones
Se utilizarán verbos consistentes para nombrar los métodos:
- `obtener`: recuperar información, por ejemplo, `obtenerTurnosDisponibles()`.
- `listar`: consultar colecciones, por ejemplo, `listarProfesionales()`.
- `buscar`: localizar información según un criterio, por ejemplo, `buscarPaciente()`.
- `solicitar`: iniciar una solicitud, por ejemplo, `solicitarTurno()`.
- `confirmar`: confirmar una operación, por ejemplo, `confirmarTurno()`.
- `cancelar`: anular una operación, por ejemplo, `cancelarTurno()`.
- `registrar`: incorporar información nueva, por ejemplo, `registrarPaciente()`.
- `actualizar`: modificar información existente, por ejemplo, `actualizarDatosPaciente()`.
- `validar`: comprobar datos o condiciones, por ejemplo, `validarDatosTurno()`.

### 4. Criterios generales
- Se priorizará la reutilización de componentes para evitar duplicar código.
- Los nombres de clases, métodos y variables deberán ser claros y coherentes con la terminología del sistema.
- Las funcionalidades que involucren información clínica se mantendrán diferenciadas de las operaciones administrativas, de acuerdo con la organización del proyecto.
- Las convenciones serán aplicadas por todos los integrantes del equipo y se revisarán cuando sea necesario.