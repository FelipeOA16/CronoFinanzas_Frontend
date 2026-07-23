# Contrato de Diseño de CronoFinanzas

Este paquete inicia la documentación oficial de UX/UI del producto.

## Documentos incluidos

- `00_MANIFESTO.md`: filosofía, propósito, transformación e identidad esencial.
- `01_PRODUCT_VISION.md`: traducción operativa del manifiesto a criterios de experiencia.

## Estado

Versión inicial `0.1`. Estos documentos ya pueden utilizarse como contexto obligatorio para Codex, pero todavía deben completarse con:

- `02_EXPERIENCE_PRINCIPLES.md`
- `03_BRAND_GUIDE.md`
- `04_UX_WRITING.md`
- `05_COMPONENT_LIBRARY.md`
- `06_SCREEN_PATTERNS.md`
- `07_RESPONSIVE_RULES.md`
- `08_MOTION_SYSTEM.md`
- `09_VISUAL_BACKLOG.md`
- `CHANGELOG.md`

## Regla para Codex

Antes de modificar una pantalla o componente, Codex debe leer los documentos existentes en `docs/design/`.

Prompt base:

> Antes de escribir código, revisa todos los documentos vigentes de `docs/design/`. Toda decisión debe respetar el manifiesto y la visión de producto. Si una solicitud entra en conflicto con estos documentos, no la implementes silenciosamente: identifica el conflicto y propone una alternativa alineada.

## Fuente de verdad

Los documentos aprobados en esta carpeta son la fuente de verdad. Las referencias visuales externas, ideas nuevas y experimentos no reemplazan estos criterios hasta quedar evaluados y registrados en el changelog.
