# Registro de evidencias V1

Este directorio documentará evidencias sanitizadas de ejecución. No debe almacenar secretos, credenciales, tokens, cadenas de conexión, datos financieros reales ni capturas que expongan información sensible.

## Fuentes operativas observadas al 13 de agosto de 2026

- **Render:** backend desplegado desde el commit `18559e036fcccbc5850d5a4504bb0283d0513fd4`.
- **Firebase Hosting:** captura observada con versión abreviada `2ae55b`; todavía no está reconciliada con el `main` actual del frontend `e83c740299d869693065ac8d4aa4a521cb2f6ce6`.
- **Supabase:** proyecto saludable, sin backup visible y con advertencias críticas de RLS deshabilitado en tablas del esquema público.
- **Alembic:** evidencia documental del backend señala `0014_capturas_rapidas` como head; debe verificarse la revisión real del entorno antes de cualquier migración.

## Reglas de evidencia

Cada evidencia debe registrar:

- bloque;
- versión candidata;
- fecha y zona horaria;
- ambiente;
- plataforma/dispositivo;
- comando o recorrido ejecutado;
- resultado esperado y observado;
- commit o PR;
- responsable;
- defectos relacionados.

Las imágenes o grabaciones de beta requieren consentimiento y datos ficticios o de bajo riesgo.
