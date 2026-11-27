---
name: mvvm-itu
description: Estándar obligatorio de arquitectura en capas y MVVM en Flutter (ChangeNotifier + ListenableBuilder) según la cátedra de Programación de Aplicaciones para Celulares del ITU. Úsalo siempre al crear, analizar o refactorizar pantallas, ViewModels, repositorios, servicios o modelos.
---

# Arquitectura en Capas y MVVM (Cátedra ITU)

## 1. Regla de Oro de Dependencias
Las dependencias van en un solo sentido hacia abajo:
`View (UI) -> ViewModel -> Repositorio -> Servicio`
La UI conoce a los datos; los datos NUNCA conocen a la UI. Ninguna capa puede saltearse un escalón.

## 2. Estructura de Carpetas (`lib/`)
- `lib/main.dart`: ÚNICO lugar donde se instancian e inyectan las piezas de abajo hacia arriba (`Service` -> `Repository` -> `ViewModel` -> `Screen`).
- `lib/domain/models/`: Clases Dart puras que representan entidades del dominio. PROHIBIDO importar `package:flutter/...`.
- `lib/data/services/`: Hablan con el exterior (API REST, Firebase/Supabase, SQLite, archivos). Devuelven datos crudos (`Map<String, dynamic>`, listas crudas) mediante `Future` o `Stream`. NO guardan estado entre llamadas ni aplican reglas de negocio.
- `lib/data/repositories/`: Fuente de verdad. Constan de un contrato (`abstract class <Entidad>Repository`) y su implementación (`<Entidad>RepositoryRemoto` o similar). Reciben el `Service` por constructor. Convierten datos crudos en modelos de dominio (`fromJson`), manejan caché en memoria y errores. Un repositorio NO conoce a otros repositorios.
- `lib/ui/<funcionalidad>/view_models/`: Clases `<Funcionalidad>ViewModel extends ChangeNotifier`. Reciben el contrato `Repository` por constructor. Guardan el estado de la pantalla (`enum` de estado, listas privadas expuestas con `List.unmodifiable`) y exponen comandos (métodos) y textos formateados. PROHIBIDO importar `material.dart` o recibir `BuildContext`.
- `lib/ui/<funcionalidad>/widgets/`: Vistas (`<Funcionalidad>Screen`) y sub-widgets auxiliares. Escuchan al ViewModel con `ListenableBuilder`. Solo dibujan el estado y llaman comandos del ViewModel. PROHIBIDO llamar servicios, hacer cálculos, convertir JSON o instanciar el ViewModel dentro de `build()`.
- `lib/ui/core/`: Widgets reutilizables, temas y funciones de formato compartidas entre pantallas.

## 3. Errores Graves a Evitar o Corregir
- **Filtración de datos a la UI**: Llamar a un `Service` o hacer `Future.delayed` dentro de un widget.
- **ViewModel acoplado a Flutter**: Usar `BuildContext` (ej. para `Navigator` o `SnackBar`) dentro del ViewModel. El ViewModel expone un estado de error y la `Screen` reacciona.
- **Acoplamiento fuerte**: Que el ViewModel dependa de la clase concreta del repositorio en lugar de la `abstract class`, o que una clase instancie sus propias dependencias en vez de recibirlas por constructor.
- **Estado mutable expuesto**: Devolver `_lista` directamente en un getter en vez de `List.unmodifiable(_lista)`.