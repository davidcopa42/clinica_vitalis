# Clínica Vitalis

Aplicación Flutter para que los pacientes de la clínica gestionen sus turnos,
registren síntomas, consulten su historia clínica y mantengan su perfil.
El backend es Firebase (Auth y Firestore) más una base SQLite local.

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

## Comandos

Requisitos: Flutter con Dart SDK 3.3 o superior, y un dispositivo o emulador
para ejecutar la app (Firebase se inicializa al arrancar).

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