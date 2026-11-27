---
name: clean-dart-itu
description: Reglas de código limpio en Dart y Flutter según Effective Dart y la cátedra del ITU. Úsalo siempre al escribir, revisar o refactorizar código Dart, widgets, nombres de variables, funciones o documentación.
---

# Código Limpio en Dart y Flutter (Cátedra ITU)

## 1. Nomenclatura (Effective Dart)
- **Idioma**: Español para todo el dominio y lógica de negocio (`cargarTurnos`, `estaCargando`, `TurnoRepository`); inglés solo para APIs propias de Flutter (`build`, `notifyListeners`). Nunca usar tildes ni `ñ` en identificadores.
- **Formato de nombres**:
    - `UpperCamelCase`: Clases, enums, extensiones y typedefs (`TurnoViewModel`, `EstadoCarga`, `HttpService` — siglas de >2 letras como palabra normal).
    - `lowerCamelCase`: Variables, parámetros, métodos, propiedades, valores de enum y constantes (`descuentoMaximo = 0.3` — PROHIBIDO `MAYUSCULAS` o prefijo `k`).
    - `lowercase_with_underscores`: Archivos, carpetas y prefijos de import (`turno_view_model.dart`).
- **Semántica**:
    - Variables/propiedades: sustantivos claros (nada de `x`, `aux`, `tmp`, `data`, `l`, `e`).
    - Booleanos: pregunta positiva de sí/no (`estaCargando`, `tieneTurnos`, `puedeConfirmar`).
    - Métodos de acción: verbo en infinitivo (`cargar()`, `agendarTurno()`).
    - Getters: sustantivos sin prefijo `get` (`totalTexto`, nunca `getTotalTexto()`). Deben ser rápidos y sin efectos secundarios.

## 2. Funciones y Lógica
- **Responsabilidad única**: Una función hace una sola cosa. Si hace varias, dividir en getters o funciones privadas.
- **Cláusulas de guarda**: Usar retornos tempranos (`if (!puedeConfirmar) return;`) en lugar de `if` anidados.
- **Parámetros**: Evitar booleanos posicionales; usar parámetros con nombre (`obtenerTurnos(forzarRecarga: true)`). Si una función recibe más de 3-4 parámetros, agruparlos en una clase modelo.
- **Sin números mágicos**: Extraer valores literales a constantes con nombre (`const centavosPorPeso = 100;`).
- **DRY**: No duplicar reglas de formato o cálculo; centralizar en funciones o getters.

## 3. Widgets Limpios
- **Clases, no métodos**: Extraer partes de un `build()` largo en clases `StatelessWidget` separadas en su propio archivo. PROHIBIDO crear métodos privados que devuelvan `Widget` (nada de `Widget _buildItem()`).
- **Desacoplamiento**: Los widgets hijos reciben solo los datos que muestran (`String`, modelos) y callbacks (`VoidCallback? onConfirmar`), no el ViewModel completo si no lo necesitan.
- **Inmutabilidad**: Usar `const` en constructores y widgets siempre que sea posible.
- **Cero lógica en `build()`**: Ningún cálculo ni formateo dentro de `build()`.

## 4. Modularidad, Imports y Documentación
- **Un archivo por clase pública**: El nombre del archivo debe coincidir con la clase pública que contiene. Clases privadas auxiliares llevan `_` al inicio.
- **Orden de imports**: 1) `dart:`, 2) `package:`, 3) rutas relativas (`../`). Separados por una línea en blanco y ordenados alfabéticamente. Eliminar imports sin uso.
- **Comentarios**: Usar `///` (doc comments) en clases y métodos públicos de `data/` y `view_models/`, empezando con una oración resumen terminada en punto y encerrando referencias en corchetes (`[TurnoService]`). Eliminar todo el código viejo comentado.