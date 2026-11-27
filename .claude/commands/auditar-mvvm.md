---
description: Audita el proyecto contra MVVM, Código Limpio y Code Smells del ITU, y arma un plan de pasos chicos.
---

Activa los skills `mvvm-itu`, `clean-dart-itu` y `refactoring-itu`.
Analiza todo el directorio `lib/` y `test/` del proyecto actual y genera un diagnóstico sin modificar archivos:

1. **Auditoría de Arquitectura MVVM**: Lista todas las violaciones por módulo (ej. vistas creando ViewModels en `initState` o llamando servicios, `BuildContext` en ViewModels, repositorios sin contrato `abstract class`, dependencias opcionales/internas).
2. **Catálogo de Code Smells**: Identifica los olores presentes (*Nombre misterioso*, *Datos expuestos*, *Número mágico*, *Código duplicado*, *Obsesión por los primitivos*, *Condicionales anidados*, *Lógica fuera de lugar*, *Comentarios desodorante*, *Código muerto*).
3. **Auditoría de Red de Seguridad (`test/`)**: Indica qué módulos o ViewModels carecen de tests y necesitan pruebas de caracterización antes de tocarse.
4. **Plan de Pasos Chicos**: Propón una tabla ordenada de pasos incrementales (de lo más seguro a lo más delicado), separando "mover de capa" de "limpiar código", indicando qué test corre y qué commit se hace en cada paso.

NO modifiques ningún archivo todavía. Espera mi confirmación.