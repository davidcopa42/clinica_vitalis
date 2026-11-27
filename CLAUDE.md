# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Estándares Obligatorios (Skills)
Antes de analizar, crear o refactorizar cualquier archivo en `lib/` o `test/`, aplica estrictamente las reglas de:
- `.claude/skills/mvvm-itu/SKILL.md`
- `.claude/skills/clean-dart-itu/SKILL.md`
- `.claude/skills/refactoring-itu/SKILL.md`

## Proyecto

Clínica Vitalis — app Flutter (Dart SDK >=3.3) para que los pacientes gestionen turnos, síntomas, historia clínica y perfil. El backend es Firebase (Auth + Firestore) más SQLite local.

## Comandos

```bash
flutter pub get
flutter run                                   # requiere dispositivo/emulador; Firebase se inicializa al arrancar
flutter analyze                               # lints: flutter_lints + prefer_const_constructors, prefer_single_quotes, directives_ordering, always_declare_return_types
dart format lib test                          # page_width 80
flutter test                                  # todos los tests
flutter test test/auth/sesion_view_model_test.dart          # un solo archivo
flutter test --plain-name "nombre del test"                 # un solo test por nombre
dart run flutter_launcher_icons               # regenera los íconos desde assets/images/logo_vitalis.png
```[cite: 45]

## Arquitectura Objetivo (MVVM en Capas — Cátedra ITU)

Las dependencias van en un solo sentido: `View -> ViewModel -> Repositorio -> Servicio`.

- `lib/main.dart`: **Único lugar** donde se instancian e inyectan todas las dependencias de abajo hacia arriba (`Service` -> `Repository` -> `ViewModel` -> `Screen`).
- `domain/models/`: Modelos Dart puros (`Paciente`, `Turno`, `Profesional`, `RegistroClinico`) con `fromMap`/`toMap`/`copyWith`, y `evento_de_app.dart` (jerarquía sellada `EventoDeApp`). Prohibido importar `flutter`.
- `data/services/`: Acceso directo a sistemas externos (Firebase Auth, Firestore, SQLite, notificaciones, conectividad). Devuelven datos crudos (`Future`/`Stream`) y **no guardan estado**.
- `data/repositories/`: Fuente de verdad. Deben tener un contrato (`abstract class <Entidad>Repository`) y una implementación que recibe su `Service` como parámetro `required` en el constructor (nunca instanciado por defecto adentro). Convierten datos crudos a modelos, cachean en memoria y manejan errores.
- `ui/<feature>/view_models/`: Clases `<Feature>ViewModel extends ChangeNotifier`. Reciben los contratos `Repository` por constructor (`required`). Exponen estado mediante getters inmutables (`List.unmodifiable`) y enums (`EstadoCarga`). Prohibido importar `material.dart` o usar `BuildContext`.
- `ui/<feature>/widgets/`: Pantallas (`<Feature>Screen`) y componentes reutilizables (`TurnoCard`). Reciben su `ViewModel` por constructor (nunca lo crean en `initState` ni `build`) y se reconstruyen con `ListenableBuilder`. Helpers compartidos en `ui/core/`.

## Contexto Funcional y Flujos del Proyecto

- **Puerta de sesión**: `main.dart` → `PuertaSesion` → `SesionViewModel` calcula `EstadoSesion` (`sinSesion` → `correoSinVerificar` → `perfilIncompleto` → `lista`) a partir de `AuthRepository.cambiosDeSesion` y el perfil en Firestore[cite: 45].
- **Turnos**: Guardados localmente en SQLite (`BaseDatosService`, tabla `turnos`, versión de esquema 1). Cancelar actualiza `estado = cancelado` en lugar de borrar. `TurnoRepository.guardarTurno` verifica disponibilidad y lanza `TurnoNoDisponibleException`. Profesionales iniciales en `datos_ejemplo.dart`[cite: 45].
- **Historia clínica**: Simulada en `HistoriaClinicaRepository` (registros de ejemplo, demora de 1 s, flag `simularError`)[cite: 45].
- **Comunicación entre módulos / Bus de eventos**: `TurnoViewModel` publica `TurnoConfirmadoEvento` mediante `EventoDeApp` (inyectado por constructor, evitando singletons globales acoplados a la UI) para que `MisTurnosViewModel` e `InicioViewModel` reaccionen[cite: 45].
- **Borradores y ciclo de vida**: `SintomasScreen` y `SolicitarTurnoScreen` usan `AppLifecycleListener` para guardar/restaurar borradores en `SharedPreferences` (claves `borrador_*`)[cite: 45].
- **Notificaciones**: `NotificacionesService` inicializado en `main()` e inyectado donde corresponda; programa recordatorios con `flutter_local_notifications` + `timezone`[cite: 45].

## Tests

Los tests usan fakes escritos a mano que hacen `implements` del contrato abstracto del repositorio (ver `test/auth/sesion_view_model_test.dart`) — sin librería de mocks[cite: 45].

## Convenciones (del README y Cátedra)

- Todos los identificadores en **español** (clases, métodos, variables), manteniendo los términos técnicos de Flutter (`build`, `notifyListeners`). Sin tildes ni `ñ`[cite: 45].
- Archivos en `snake_case`, clases en `PascalCase`, miembros y constantes en `camelCase`[cite: 45].
- Pantallas nombradas uniformemente como `<Funcionalidad>Screen` (unificar `*Page` a `*Screen`); componentes reutilizables según su función (`TurnoCard`)[cite: 45].
- Verbos en infinitivo para métodos: `obtener`, `listar`, `buscar`, `solicitar`, `confirmar`, `cancelar`, `registrar`, `actualizar`, `validar`[cite: 45].
- No editar archivos generados de plugins en `linux/`, `macos/` y `windows/`[cite: 45].