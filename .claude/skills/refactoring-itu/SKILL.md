---
name: refactoring-itu
description: Metodología obligatoria de refactoring seguro en pasos chicos, detección de code smells, pruebas de caracterización y commits atómicos según la cátedra del ITU. Úsalo siempre antes y durante cualquier refactorización.
---

# Metodología de Refactoring Seguro (Cátedra ITU)

## 1. Regla de los Dos Sombreros
- **Sombrero de Refactorizar**: Cambiar la estructura interna sin alterar el comportamiento observable. PROHIBIDO agregar nuevas funcionalidades o cambiar resultados de negocio mientras se refactoriza. Si se detecta un bug real, documentarlo o corregirlo en un commit separado tras escribir un test que lo demuestre.
- **No reescribir desde cero**: Transformar el código existente en pasos incrementales manteniendo la app compilando y funcionando en cada paso.

## 2. Red de Seguridad (Tests Antes de Tocar Código)
- **Sin pruebas no hay refactoring**: Antes de modificar un ViewModel, repositorio o flujo sin cobertura suficiente, escribir **pruebas de caracterización** que verifiquen el comportamiento externo actual (qué devuelve, qué estado emite, qué envía al repositorio/servicio), sin acoplarse a detalles internos que van a cambiar.
- Ejecutar `flutter test` antes de iniciar y después de cada cambio chico. Nunca dejar tests en rojo.

## 3. Reglas de Ejecución Paso a Paso
- **Mover y mejorar por separado**: Primero mover/extraer archivos a la capa correspondiente manteniendo la lógica intacta -> correr `flutter test` -> hacer commit. En un paso posterior, limpiar nombres, encapsular y extraer métodos.
- **Orden seguro**:
    1. Renombrar identificadores misteriosos (`cvm`, `l`, `e`, `f`) y convertir métodos simples en getters.
    2. Encapsular campos privados (`_`) y exponer getters de solo lectura (`List.unmodifiable`).
    3. Reemplazar booleanos posicionales por parámetros con nombre y números mágicos por constantes.
    4. Extraer métodos/getters para eliminar código duplicado y aplicar cláusulas de guarda (retornos tempranos).
    5. Reemplazar primitivos de estado (`int`, `String`) por `enum`.
    6. Mover lógica fuera de lugar a la capa que corresponde y eliminar comentarios desodorante y código muerto.
- **Commits atómicos**: Tras cada paso en verde (`flutter test`), hacer un commit descriptivo (ej. `"Extraer contrato TurnoRepository"`, `"Encapsular estado en TurnoViewModel"`). Si un cambio rompe tests y no se resuelve rápido, revertir con `git restore .` y dividir en un paso más pequeño.

## 4. Code Smells a Detectar en Auditorías
Identificar explícitamente por su nombre: *Nombre misterioso*, *Datos expuestos*, *Argumento bandera*, *Número mágico*, *Código duplicado*, *Obsesión por los primitivos*, *Condicionales anidados*, *Lógica fuera de lugar*, *Comentarios desodorante* y *Código muerto*.