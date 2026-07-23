# CronoFinanzas — Principios de Experiencia

**Versión:** 0.1  
**Estado:** Base operativa  
**Depende de:** `00_MANIFESTO.md`, `01_PRODUCT_VISION.md`  
**Ámbito:** Mobile, tablet y web

## 1. Propósito

Este documento traduce el manifiesto y la visión de CronoFinanzas en reglas concretas de UX. Toda pantalla, flujo, componente, texto o interacción debe poder evaluarse con estos principios.

## 2. Principio rector

> CronoFinanzas debe ayudar al usuario a comprender mejor su relación con el dinero y tomar decisiones con mayor conciencia.

Una solución no debe aprobarse si dificulta comprender la información, aumenta pasos sin aportar valor, genera culpa o ansiedad, confunde conceptos financieros, reduce la autonomía o rompe la coherencia del sistema.

## 3. Persona antes que dato

La persona es el centro. Los datos son instrumentos para ayudarla a comprenderse.

**Debemos:**
- explicar qué significa la información;
- relacionar datos con hábitos, metas o decisiones;
- utilizar lenguaje cotidiano;
- mostrar contexto;
- permitir corregir errores fácilmente.

**Evitamos:**
- cifras sin explicación;
- lenguaje contable innecesario;
- pantallas que parezcan formularios de una base de datos;
- métricas sin utilidad para decidir.

## 4. Claridad antes que decoración

1. El dato principal debe identificarse rápidamente.
2. Cada sección debe tener una jerarquía visible.
3. Las metáforas naturales o andinas no sustituyen etiquetas necesarias.
4. Los fondos, patrones e ilustraciones deben conservar la legibilidad.
5. El color no será el único medio para comunicar un estado.
6. Los elementos decorativos no deben parecer interactivos.

Una pantalla debe revisarse si contiene demasiados colores destacados, tarjetas dentro de tarjetas, ilustraciones que desplazan información o varios elementos compitiendo por atención.

## 5. Cotidianidad antes que solemnidad

Gestionar las finanzas debe sentirse natural y breve.

La experiencia debe:
- permitir registrar rápidamente;
- reducir campos obligatorios;
- recordar información frecuente cuando sea seguro;
- permitir completar detalles después;
- conservar el contexto al volver;
- evitar confirmaciones innecesarias.

## 6. Reflexión antes que imposición

CronoFinanzas acompaña mediante observaciones y preguntas, no mediante órdenes.

**Correcto:**
- “¿Qué cambió este mes en tus gastos?”
- “Este compromiso se repite cada mes. ¿Deseas considerarlo en tu presupuesto?”
- “Estás más cerca de tu meta que el mes anterior.”

**Incorrecto:**
- “Estás gastando mal.”
- “Debes ahorrar más.”
- “Has fallado tu presupuesto.”

No toda pantalla necesita una pregunta. La reflexión aparece solo cuando existe información suficiente y aporta comprensión.

## 7. Progreso antes que perfección

CronoFinanzas reconoce que la vida financiera es cambiante y corregible.

Debemos:
- permitir editar;
- conservar borradores cuando sea posible;
- distinguir pendiente, incompleto y error;
- reconocer avances pequeños;
- evitar presentar una meta incompleta como fracaso;
- explicar consecuencias antes de eliminar.

## 8. Una acción principal por contexto

Cada pantalla, modal o panel debe tener una acción dominante.

Jerarquía:
1. Acción principal.
2. Acciones secundarias.
3. Acciones terciarias.
4. Acciones destructivas.

Reglas:
- no habrá dos botones primarios con igual peso dentro del mismo bloque;
- el botón debe describir la acción: `Guardar movimiento`, no `Aceptar`;
- las acciones destructivas estarán separadas;
- en mobile, la acción principal debe ser accesible sin cubrir información;
- en web, el espacio disponible no justifica multiplicar acciones destacadas.

## 9. Profundidad progresiva

La experiencia comienza simple y permite profundizar.

**Nivel 1 — Esencial:** monto, tipo, cuenta, fecha y acción principal.  
**Nivel 2 — Contexto:** categoría, nota, etiquetas, recurrencia y relaciones.  
**Nivel 3 — Análisis:** comparaciones, tendencias, patrones y reflexión.

No se mostrará el nivel 3 cuando el usuario solo necesite completar una tarea del nivel 1.

## 10. Consistencia antes que novedad

Se reutilizan componentes, términos, iconos, estados y patrones existentes.

Un componente nuevo solo se justifica cuando:
- el actual no resuelve el problema;
- la diferencia es funcional;
- servirá en más de un contexto;
- se documentará;
- incluye comportamiento mobile y web;
- reemplaza o amplía claramente otro patrón.

## 11. Información financiera sin ambigüedad

Nunca se utilizarán como equivalentes:
- saldo;
- dinero disponible;
- presupuesto restante;
- ahorro;
- patrimonio;
- ingreso;
- transferencia;
- deuda;
- préstamo;
- compromiso futuro.

Cada cifra importante debe indicar qué representa, el periodo correspondiente y si es actual, estimada o pendiente.

**Incorrecto:** `Disponible: S/ 850`  
**Correcto:** `Saldo total en cuentas: S/ 850` o `Presupuesto disponible este mes: S/ 850`.

## 12. Estados visibles y comprensibles

Toda función debe contemplar:
- inicial;
- cargando;
- vacío;
- éxito;
- error recuperable;
- error de sesión;
- sin conexión;
- deshabilitado;
- pendiente;
- completado.

Nunca se dejará una pantalla en blanco durante una carga. Todo error recuperable tendrá una acción. El usuario debe saber si una operación se guardó.

## 13. Prevención y recuperación de errores

La interfaz debe prevenir antes de corregir.

**Prevención:** valores seguros, validación cercana al campo, formatos visibles, acciones imposibles deshabilitadas y distinción clara entre origen y destino.

**Recuperación:** conservar datos, indicar qué corregir, permitir reintentar, evitar reiniciar formularios y no culpar al usuario.

## 14. Navegación predecible

### Mobile
- navegación principal estable;
- bottom navigation para destinos frecuentes;
- bottom sheets para tareas breves;
- pantallas completas para procesos complejos;
- comportamiento consistente del botón atrás.

### Web
- navegación lateral persistente;
- encabezados claros;
- acciones relacionadas agrupadas;
- no depender exclusivamente de hover.

La misma función conserva nombre, icono y propósito entre plataformas, aunque cambie de ubicación.

## 15. Mobile no es web comprimida

### Mobile prioriza
- una columna;
- información esencial;
- controles táctiles;
- lectura vertical;
- acciones frecuentes;
- menor densidad.

### Web prioriza
- comparación;
- paneles simultáneos;
- mayor densidad;
- filtros persistentes;
- aprovechamiento horizontal.

Está prohibido reducir una pantalla web hasta hacerla caber en mobile sin revisar su jerarquía.

## 16. Accesibilidad desde el diseño

Mínimos obligatorios:
- contraste suficiente;
- texto escalable;
- áreas táctiles adecuadas;
- foco visible en web;
- navegación por teclado;
- etiquetas semánticas;
- no depender solo del color;
- compatibilidad con reducción de movimiento;
- mensajes comprensibles para lectores de pantalla.

## 17. Calma visual

La calma significa control de atención.

Usamos:
- espacios consistentes;
- agrupación clara;
- superficies moderadas;
- textos concisos;
- color de énfasis reservado.

Evitamos:
- animaciones constantes;
- alertas llamativas sin urgencia;
- números rojos como castigo;
- banners permanentes;
- múltiples degradados;
- exceso de tarjetas y emojis.

## 18. Movimiento con propósito

Toda animación debe explicar una transición, confirmar una acción, mostrar relación, orientar la atención o comunicar progreso.

Debe ser breve, predecible, interrumpible y respetar la reducción de movimiento.

## 19. Privacidad y confianza visibles

La interfaz debe:
- explicar permisos antes de solicitarlos;
- evitar exponer datos sensibles;
- permitir ocultar montos;
- confirmar cambios críticos;
- diferenciar claramente cuentas de prueba, personales y administrativas cuando corresponda.

## 20. Criterio para Yachay

Yachay es guía, no juez ni protagonista permanente.

Debe:
- aportar interpretación;
- hacer preguntas útiles;
- aparecer en momentos relevantes;
- hablar con calma;
- respetar la autonomía.

No debe:
- repetir datos;
- aparecer en todas las pantallas;
- bloquear acciones;
- infantilizar;
- ordenar;
- fingir certeza.

Extensión recomendada: una idea principal en una o dos frases.

## 21. Lista de verificación de pantalla

### Propósito
- [ ] Tiene un objetivo claro.
- [ ] El usuario entiende qué puede hacer.
- [ ] La acción principal es evidente.

### Información
- [ ] El dato principal tiene jerarquía.
- [ ] Los términos financieros son precisos.
- [ ] El periodo y contexto están claros.

### Interacción
- [ ] Evita pasos innecesarios.
- [ ] Conserva datos ante errores.
- [ ] Incluye carga, vacío, error y éxito.

### Identidad
- [ ] Transmite calma, claridad y confianza.
- [ ] La identidad no compite con los datos.
- [ ] Yachay aparece solo si aporta valor.

### Adaptación
- [ ] Mobile fue diseñado para mobile.
- [ ] Web aprovecha el espacio sin saturar.
- [ ] Ambas versiones conservan el mismo significado.

### Accesibilidad
- [ ] No depende únicamente del color.
- [ ] Los controles tienen tamaño suficiente.
- [ ] Es navegable con teclado en web.
- [ ] Los estados son comprensibles.

## 22. Regla de aprobación

Una pantalla puede implementarse cuando:
1. respeta el manifiesto;
2. cumple estos principios;
3. utiliza componentes existentes o documenta uno nuevo;
4. define mobile y web;
5. contempla estados completos;
6. tiene textos claros;
7. identifica qué mejora;
8. puede validarse con una tarea real.

## 23. Regla para Codex

Antes de modificar UX/UI, Codex debe:
1. leer `00_MANIFESTO.md`;
2. leer `01_PRODUCT_VISION.md`;
3. leer este documento;
4. reutilizar el Design System;
5. documentar conflictos;
6. evitar cambios fuera del alcance;
7. entregar evidencia de mobile y web;
8. ejecutar análisis y pruebas;
9. actualizar el changelog cuando corresponda.

Codex no debe interpretar “modernizar” como permiso para cambiar colores, componentes y estructuras de forma indiscriminada.
