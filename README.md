# Clínica Vitalis

Aplicación móvil desarrollada en Flutter para la gestión de turnos y servicios de una clínica. Permite a los pacientes crear una cuenta, solicitar y cancelar turnos con profesionales de distintas especialidades, registrar sus síntomas y consultar su historia clínica desde el celular.

## Módulos

### Autenticación
- Registro e inicio de sesión con correo y contraseña, o con una cuenta de Google, mediante **Firebase Authentication**.
- Verificación del correo electrónico y recuperación de contraseña.
- Al ingresar por primera vez, el paciente completa su perfil (nombre, apellido, teléfono, obra social), que se guarda en **Cloud Firestore**.
- `PuertaSesion` decide qué pantalla mostrar según el estado de la sesión (login, verificar correo, completar perfil o inicio).
- Código: `lib/ui/auth/`, `lib/data/repositories/auth_repository.dart`, `lib/data/services/auth_service.dart`.

### Turnos
- El paciente elige especialidad, profesional, fecha y horario, y la app muestra solo los horarios disponibles.
- Al confirmar, se muestra la pantalla **Turno confirmado** con los datos del paciente y del turno (con una animación de aparición `FadeTransition`).
- Desde esa pantalla se puede activar un recordatorio: una notificación local un día antes del turno (`flutter_local_notifications`).
- En **Mis turnos** se listan los turnos solicitados y se pueden cancelar.
- Los turnos se guardan localmente con **SQLite** (`sqflite`).
- Código: `lib/ui/turnos/`, `lib/data/repositories/turno_repository.dart`, `lib/data/services/base_datos_service.dart`.

### Síntomas
- El paciente selecciona sus síntomas de una lista, indica la duración y la intensidad (escala 1 a 10) y puede agregar una descripción.
- Si marca síntomas de alarma (dolor de pecho, falta de aire, pérdida de conocimiento, etc.) o una intensidad muy alta, la app lo advierte y sugiere buscar atención urgente.
- El formulario se guarda como borrador con `shared_preferences`, para no perder lo cargado al salir de la pantalla.
- Desde el registro de síntomas se puede ir directamente a solicitar un turno.
- Código: `lib/ui/sintomas/`.

### Historia clínica
- Muestra los registros clínicos del paciente (análisis, estudios y recetas), con filtros por tipo.
- Cada registro abre una pantalla de detalle.
- Maneja los estados de carga, error (con botón "Reintentar") y lista vacía.
- Por ahora los registros son datos de ejemplo.
- Código: `lib/ui/historia_clinica/`, `lib/data/repositories/historia_clinica_repository.dart`.

### Otros
- **Perfil y ajustes**: ver y editar los datos del paciente (`lib/ui/perfil/`).
- **Conectividad**: aviso cuando el dispositivo se queda sin conexión a internet (`lib/ui/conectividad/`).

## Arquitectura

El proyecto separa la interfaz de la lógica y del acceso a datos:

```
lib/
├── domain/        # Modelos (Paciente, Profesional, Turno, RegistroClinico) y eventos
├── data/
│   ├── repositories/  # Acceso a datos que usan los ViewModels
│   └── services/      # Firebase, SQLite, notificaciones, conectividad
└── ui/
    └── <modulo>/
        ├── view_models/   # Estado y lógica de cada pantalla (ChangeNotifier)
        └── widgets/       # Pantallas y componentes visuales
```

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

### Tests
```bash
flutter test
```


## Convenciones

### 1. Idioma y nomenclatura
- Utilizaremos el español para los nombres de clases, variables, métodos y componentes, manteniendo los términos técnicos propios de Flutter cuando corresponda.
- Los archivos Dart se nombrarán en `snake_case`, por ejemplo: `solicitar_turno.dart` y `historia_clinica.dart`.
- Las clases utilizarán `PascalCase`, por ejemplo: `Paciente`, `Profesional`, `Turno` y `HistoriaClinica`.
- Las variables y los métodos utilizarán `camelCase`, por ejemplo: `nombrePaciente`, `fechaTurno` y `obtenerTurnosDisponibles()`.
- Los nombres deberán ser descriptivos y representar claramente la información o responsabilidad correspondiente.

### 2. Organización de pantallas y componentes
- Las pantallas principales utilizarán nombres relacionados con la funcionalidad que representan, por ejemplo: `InicioScreen`, `SolicitarTurnoScreen`, `HistoriaClinicaScreen` y `TurnoConfirmadoScreen`.
- Los componentes reutilizables tendrán nombres que describan su función, por ejemplo: `TurnoCard`, `ProfesionalCard` y `SelectorEspecialidad`.
- Los modelos representarán las entidades principales del sistema, como pacientes, profesionales, turnos y registros de historia clínica.
- La lógica de acceso a datos y las operaciones del sistema se mantendrán separadas de los componentes visuales cuando la arquitectura del proyecto lo permita.
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