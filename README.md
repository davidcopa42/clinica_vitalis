# clinica_vitalis

Aplicación para la gestión de turnos y servicios

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