<!-- FUENTE CANÓNICA DE ALCANCE V1. Aprobado por Felipe el 12 de agosto de 2026. No modificar decisiones de alcance sin aplicar el gobierno de cambios de la sección 16. -->

# CronoFinanzas — Contrato de alcance y salida de la Versión 1

Frontera funcional, técnica, visual y operacional para cerrar el MVP y convertirlo en un producto entregable

| **ESTADO DEL DOCUMENTO Aprobado y cerrado v0.2. Incorpora decisiones de alcance confirmadas por Felipe. Es la fuente de verdad para completar una V1 candidata interna, validarla con una beta cerrada y autorizar la salida final después de corregir bloqueadores.** |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

| **Dato**                 | **Definición**                                                                   |
|--------------------------|----------------------------------------------------------------------------------|
| Propietario del producto | Felipe Ordoñez                                                                   |
| Fecha de corte           | 12 de agosto de 2026                                                             |
| Repositorios revisados   | CronoFinanzas_Frontend y CronoFinanzas_backend, rama main                        |
| Base adicional           | Estado maestro, auditoría integral, plan de mejora y contrato visual en progreso |
| Plataformas propuestas   | Web responsive, Android e iOS                                                    |
| Salida propuesta         | V1 candidata interna → beta cerrada → V1 liberada                                |

*Este documento separa evidencia, propuesta y decisión del propietario. Que una función exista en el código no significa automáticamente que deba bloquear la V1.*

# Cómo leer y revisar este contrato

No necesitas evaluar código. Debes comprobar si la frontera propuesta representa el producto que quieres entregar primero. Las observaciones técnicas ya están traducidas a consecuencias para el usuario y condiciones de salida.

| **Marca**    | **Significado**                                                                              | **Qué debes hacer**                        |
|--------------|----------------------------------------------------------------------------------------------|--------------------------------------------|
| Confirmado   | Está respaldado por el producto implementado o por decisiones previas vigentes.              | Revisar; solo cambiar si la visión cambió. |
| Propuesta V1 | Es la opción recomendada para cerrar una primera versión confiable sin expandir el proyecto. | Aceptar, modificar o rechazar.             |
| Pendiente    | No puede resolverse solo con GitHub porque depende de una decisión de producto u operación.  | Elegir una alternativa.                    |
| Fuera de V1  | Puede ser valioso, pero no debe impedir la salida de esta versión.                           | Mantener en backlog.                       |

| **DECISIÓN PRINCIPAL PROPUESTA CronoFinanzas V1 no será la versión con todas las ideas terminadas. Será la primera versión multiplataforma en la que una persona puede registrar, comprender y revisar su situación financiera con datos consistentes, recibir notificaciones útiles y capturar movimientos rápidamente, sin ayuda directa y sin riesgo razonable de perder o mezclar información.** |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

# Resumen ejecutivo

CronoFinanzas ya posee una base funcional amplia: autenticación, cuentas, movimientos, categorías, presupuestos, reportes, deudas y préstamos, metas, alertas, captura rápida, Home y educación financiera. La V1 amplía la exigencia de salida a web, Android e iOS e incorpora como bloqueadores las notificaciones persistentes, la captura rápida móvil y la mejora funcional del Home. El problema actual no es la ausencia de funciones, sino la falta de un límite de producto y de una puerta de salida verificable.

Este contrato congela nuevas funciones fuera del alcance confirmado, cierra primero la confiabilidad financiera y los recorridos esenciales, aplica coherencia visual en web, Android e iOS, completa una V1 candidata interna y solo entonces ejecuta una beta cerrada. La V1 se declara liberada cuando se corrigen los bloqueadores encontrados en esa beta.

## Decisiones base confirmadas

- Público inicial: Felipe y un grupo pequeño de amigos cercanos como probadores reales.

- Plataformas de V1: web responsive, Android e iOS. Las tres forman parte del alcance obligatorio y deben superar pruebas funcionales y visuales.

- Alcance visual: coherencia sólida y profesional en recorridos esenciales, sin exigir completar los 11 documentos del Design System.

- Yachay/Educación: puede permanecer accesible si es estable, pero no bloquea V1 y debe etiquetarse como contenido inicial o beta.

- Alertas y notificaciones: el centro interno, los permisos, la programación, la entrega y las notificaciones persistentes del sistema forman parte obligatoria de la V1.

- Captura rápida: la burbuja o botón flotante dentro de la aplicación móvil forma parte obligatoria de la V1 en Android e iOS; debe llevar a un registro rápido sin reemplazar el formulario completo cuando se requieran más datos.

- Home: se transformará para cumplir su función de orientar al usuario. Debe priorizar situación actual, acciones y próximos compromisos; toda cifra será real y el contenido simulado se reemplazará o retirará.

- Lanzamiento: beta cerrada antes de cualquier publicación abierta.

# 1. Propósito y visión de la V1

## 1.1 Problema que debe resolver

CronoFinanzas debe permitir que una persona concentre sus cuentas y movimientos, comprenda cuánto tiene disponible, controle gastos frente a presupuestos, conozca cuánto debe o cuánto le deben y avance hacia metas financieras, sin depender de hojas separadas ni cálculos manuales.

| **PROMESA DE LA V1** Al abrir CronoFinanzas, el usuario puede confiar en que los saldos reflejan sus operaciones, entender su situación actual y registrar la siguiente acción financiera sin perderse. |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

## 1.2 Principios no negociables

- Confiabilidad antes que cantidad de funciones.

- Toda cifra financiera visible debe tener una fuente real y explicable.

- Una operación se registra una sola vez y actualiza coherentemente todos los módulos relacionados.

- Los datos de un usuario no pueden ser consultados ni modificados por otro.

- La interfaz debe orientar sin imponer una única forma de administrar el dinero.

- Web, Android e iOS pueden adaptar su distribución e interacción, pero deben mantener el mismo significado, reglas financieras y continuidad de datos.

- Toda función no esencial se aplaza si pone en riesgo el cierre de la V1.

## 1.3 Usuario inicial

La V1 está diseñada para una persona que administra finanzas personales en soles, registra ingresos y gastos manualmente y necesita una visión clara de cuentas, presupuestos, deudas y objetivos. No se diseña todavía para contabilidad empresarial, hogares multiusuario, asesores financieros ni sincronización bancaria.

## 1.4 Resultado esperado

Después de usar la aplicación durante varios días, el usuario debe poder responder sin cálculos externos: cuánto dinero tiene, en qué gastó, cuánto puede gastar según su presupuesto, qué compromisos se aproximan, cuánto debe o le deben y cómo avanzan sus metas.

# 2. Frontera oficial de la V1

| **Entra y bloquea la V1**                                | **Entra, pero no bloquea por sí solo**  | **Fuera de V1**                  |
|----------------------------------------------------------|-----------------------------------------|----------------------------------|
| Autenticación y recuperación                             | Educación/Yachay inicial                | Gamificación avanzada            |
| Cuentas y saldos                                         | Consejos reales o etiquetados           | Sincronización bancaria          |
| Ingresos, gastos y transferencias                        | Personalización visual secundaria       | Finanzas compartidas             |
| Categorías                                               | Animaciones e ilustraciones no críticas | Intereses, cuotas y amortización |
| Presupuestos esenciales                                  | Contenido educativo ampliado            | Adjuntos y comprobantes          |
| Reportes esenciales                                      | Temas visuales adicionales              | Automatizaciones complejas       |
| Deudas/préstamos básicos                                 | Detalles premium no esenciales          | Funciones sociales               |
| Metas financieras básicas                                |                                         | Nuevos productos financieros     |
| Notificaciones internas y persistentes                   |                                         |                                  |
| Captura rápida mediante burbuja flotante móvil           |                                         |                                  |
| Compatibilidad web, Android e iOS                        |                                         |                                  |
| Home orientador con datos reales y acciones prioritarias |                                         |                                  |
| Seguridad, respaldo y pruebas                            |                                         |                                  |

## 2.1 Regla de incorporación

| **REGLA DE CONGELAMIENTO** Desde la aprobación de este contrato, una función nueva solo puede entrar en la V1 si su ausencia impide completar un recorrido esencial, produce información financiera incorrecta, compromete seguridad/recuperación o genera una confusión grave y repetible. |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

Toda otra idea se registra en el backlog con evidencia, impacto y prioridad. No se implementa durante el cierre de V1.

# 3. Alcance funcional obligatorio

La siguiente matriz define lo que cada módulo debe permitir para considerarse parte estable de V1. El estado refleja la evidencia disponible; no sustituye las pruebas de aceptación.

| **Módulo**       | **Capacidad mínima V1**                                                                               | **Estado de partida**                 | **Condición de salida**                                                                                             |
|------------------|-------------------------------------------------------------------------------------------------------|---------------------------------------|---------------------------------------------------------------------------------------------------------------------|
| Acceso           | Registro, inicio, cierre, verificación y recuperación.                                                | Implementado                          | Flujo completo probado con correos reales y errores controlados.                                                    |
| Perfil           | Consultar datos, sesiones y acciones de cuenta.                                                       | Implementado                          | Acciones sensibles confirmadas y sin exposición de datos.                                                           |
| Cuentas          | Crear, editar, consultar saldo y restringir eliminación con historial.                                | Implementado con correcciones         | Saldos consistentes y mensajes comprensibles.                                                                       |
| Movimientos      | Ingreso, gasto, transferencia, edición/eliminación segura.                                            | Implementado                          | Cada operación impacta una vez y se revierte correctamente.                                                         |
| Categorías       | Organizar movimientos y validar pertenencia al usuario.                                               | Implementado                          | Sin cruces entre usuarios ni categorías inválidas.                                                                  |
| Presupuestos     | Límite global o por categoría y consumo del periodo.                                                  | Implementado                          | Cálculo y periodo coinciden con movimientos reales.                                                                 |
| Reportes         | Resumen mensual útil de ingresos, gastos y distribución.                                              | Implementado                          | Totales reconciliados con movimientos y filtros.                                                                    |
| Deudas/préstamos | Registrar debo/me deben, pagos/cobros, saldo y reversión.                                             | Implementado                          | Pago genera movimiento vinculado sin duplicación.                                                                   |
| Metas            | Crear objetivo, aportar, revertir y ver avance.                                                       | Implementado                          | Aporte afecta cuenta y meta de forma consistente.                                                                   |
| Home             | Orientar con situación actual, prioridades, próximos compromisos y acciones útiles.                   | Implementado; requiere transformación | Jerarquía comprensible, cifras reales, actualización inmediata y ausencia de sobrecarga o simulaciones.             |
| Notificaciones   | Centro interno, permisos, programación, entrega, apertura y persistencia del sistema.                 | Implementado parcialmente             | Entrega fiable en Android e iOS, preferencias respetadas, navegación al contexto correcto y control de duplicados.  |
| Captura rápida   | Abrir registro rápido desde burbuja o botón flotante dentro de la app móvil y completar lo necesario. | Implementado; requiere revisión UX    | Accesible en Android e iOS, no tapa controles, conserva datos ante interrupciones y actualiza módulos relacionados. |
| Educación        | Mostrar contenido inicial útil.                                                                       | Implementado parcialmente             | Si permanece visible, indicar alcance y evitar promesas incompletas.                                                |

## 3.1 Reglas financieras transversales

- Una transferencia descuenta de la cuenta origen y suma a la cuenta destino dentro de una sola operación lógica.

- Un pago de deuda, cobro de préstamo o aporte a meta crea su movimiento vinculado; no exige registrarlo otra vez.

- Eliminar o revertir una operación vinculada revierte todos sus efectos o se bloquea con una explicación clara.

- No se aceptan importes nulos, negativos o superiores al saldo pendiente cuando la regla del módulo lo impide.

- Los resúmenes, reportes y Home deben refrescarse al terminar una operación, sin recargar manualmente.

- El redondeo y la moneda deben ser consistentes en almacenamiento, cálculo y presentación.

# 4. Recorridos esenciales de aceptación

Un recorrido esencial se aprueba solo si puede completarse de principio a fin en web, Android e iOS cuando corresponda, sin ayuda del propietario y con resultados coherentes en todos los módulos relacionados.

| **ID** | **Recorrido**                      | **Prueba mínima**                                                                         | **Resultado esperado**                                                                           |
|--------|------------------------------------|-------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| R1     | Crear y recuperar acceso           | Registrarse, verificar correo, iniciar sesión, cerrar sesión y restablecer contraseña.    | Acceso recuperable y sesión segura.                                                              |
| R2     | Configurar finanzas                | Crear cuenta y categorías iniciales.                                                      | Cuenta lista, saldo visible y categorías propias.                                                |
| R3     | Registrar dinero                   | Crear ingreso y gasto; editar o eliminar según reglas.                                    | Saldo, Home, presupuesto y reporte coinciden.                                                    |
| R4     | Transferir                         | Mover dinero entre dos cuentas propias.                                                   | El saldo total de las cuentas activas no cambia; los saldos individuales sí.                                                    |
| R5     | Controlar presupuesto              | Crear presupuesto y registrar gastos del periodo.                                         | Disponible y progreso se actualizan correctamente.                                               |
| R6     | Gestionar deuda                    | Crear deuda, pagar parcialmente y revertir pago.                                          | Saldo pendiente, cuenta y movimiento se reconcilian.                                             |
| R7     | Gestionar préstamo                 | Registrar dinero por cobrar, cobrar y revertir.                                           | Cobro impacta cuenta y saldo pendiente una vez.                                                  |
| R8     | Avanzar una meta                   | Crear meta, aportar y revertir aporte.                                                    | Cuenta, progreso y estado de meta coinciden.                                                     |
| R9     | Comprender el Home                 | Revisar situación después de varias operaciones.                                          | El usuario explica cada cifra sin asistencia.                                                    |
| R11    | Recibir y gestionar notificaciones | Activar permisos, generar aviso, recibirlo con la app abierta/cerrada y abrir su destino. | Notificación pertinente, no duplicada, persistente cuando corresponda y con navegación correcta. |
| R12    | Usar captura rápida móvil          | Abrir la burbuja flotante, registrar una operación y continuar o completar datos.         | Registro rápido, recuperable y reflejado una sola vez en saldo, Home y reportes.                 |
| R10    | Consultar reportes                 | Seleccionar periodo y comparar con movimientos.                                           | Totales y categorías son trazables.                                                              |

## 4.1 Criterio de aprobación por recorrido

> ☐ Resultado financiero correcto.
>
> ☐ Navegación comprensible y sin callejones sin salida.
>
> ☐ Estados de carga, vacío, éxito y error visibles.
>
> ☐ Mensajes en lenguaje comprensible.
>
> ☐ Actualización inmediata de las pantallas relacionadas.
>
> ☐ Comportamiento responsive sin desbordes, cortes ni controles inaccesibles.

# 5. Estándar visual mínimo

La V1 no requiere terminar los once documentos del contrato visual antes de iniciar las mejoras, pero sí exige documentar e implementar los patrones utilizados por el Home, las notificaciones y la captura rápida móvil. Requiere que los recorridos esenciales se perciban como un solo producto y no como pantallas creadas en momentos distintos.

## 5.1 Qué sí debe estar cerrado

- Paleta, tipografía, espaciado, radios, elevación y estados semánticos básicos.

- Botones, campos, tarjetas, diálogos, barras de navegación y mensajes reutilizables.

- Jerarquía clara de títulos, cifras, acciones primarias y secundarias.

- Estados vacío, carga, error, deshabilitado y éxito en módulos esenciales.

- Contraste y legibilidad suficientes; objetivos táctiles cómodos en móvil.

- Responsive definido para móvil, tableta y escritorio, con prioridad de contenido consistente.

- Marca CronoFinanzas y lenguaje visual Chakana aplicados con moderación y coherencia.

## 5.2 Qué puede continuar después

- Sistema completo de ilustraciones, animaciones y mascota.

- Variantes premium de todos los componentes.

- Temas alternativos y personalización extensa.

- Documentación exhaustiva de patrones que aún no se usan.

- Pulido de pantallas no esenciales o contenidos futuros.

| **ORDEN RECOMENDADO** Cerrar el documento 05 de ilustraciones, pausar 06–11 y retomarlos por bloques mientras se corrigen recorridos reales. Cada patrón se documenta, implementa y valida antes de expandirlo. |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

# 6. Seguridad, privacidad y protección de datos

La protección de datos financieros es una condición de salida, no una mejora posterior.

| **Control obligatorio** | **Criterio de aceptación**                                                                                       |
|-------------------------|------------------------------------------------------------------------------------------------------------------|
| Aislamiento por usuario | Todas las lecturas y escrituras validan el usuario autenticado; pruebas negativas intentan acceder a IDs ajenos. |
| Autenticación           | JWT, expiración, refresco, cierre de sesión y recuperación funcionan sin exponer tokens.                         |
| Secretos                | Claves de base de datos, JWT, Resend y service roles no están en frontend, repositorio, logs ni builds.          |
| CORS                    | Solo orígenes de desarrollo y producción explícitamente autorizados; sin comodines en producción.                |
| Acciones destructivas   | Eliminar cuenta, usuario o historial requiere confirmación y respeta dependencias.                               |
| Errores                 | La interfaz no expone trazas, SQL, tokens o detalles internos.                                                   |
| Transporte              | Producción usa HTTPS en frontend, API y servicios externos.                                                      |
| Dependencias            | No existen vulnerabilidades críticas conocidas sin tratamiento.                                                  |

# 7. Respaldo y recuperación

| **BLOQUEADOR ACTUAL** No se encontró una estrategia de respaldo y restauración documentada en los repositorios revisados. Antes de beta real debe existir, ejecutarse y dejar evidencia de al menos una restauración de prueba. |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

> ☐ Definir responsable y frecuencia de copia de la base de datos.
>
> ☐ Conservar copias fuera del mismo punto de fallo del servicio principal.
>
> ☐ Documentar pasos de restauración, credenciales necesarias y tiempo objetivo.
>
> ☐ Probar restauración en un entorno separado sin afectar producción.
>
> ☐ Verificar que usuarios, cuentas, movimientos y vínculos deuda/meta se recuperan coherentemente.
>
> ☐ Registrar fecha, duración, resultado y problemas de cada prueba.

# 8. Calidad técnica y pruebas mínimas

Los repositorios contienen comandos de análisis y pruebas, y el backend posee pruebas iniciales de seguridad y smoke. La V1 necesita una batería centrada en reglas financieras, no solo en que la aplicación arranque.

| **Nivel**                | **Pruebas obligatorias**                                                                                        | **Puerta de salida**                                         |
|--------------------------|-----------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------|
| Backend unitario/dominio | Saldos, transferencias, presupuestos, pagos/cobros, aportes, reversiones y ownership.                           | Todas pasan de forma repetible.                              |
| API/integración          | Autenticación y recorridos financieros contra base de prueba.                                                   | Sin efectos dobles ni acceso cruzado.                        |
| Frontend                 | Controladores, validaciones, widgets críticos, Home, estados de notificación y captura rápida.                  | Sin errores de análisis; estados principales cubiertos.      |
| End-to-end manual        | R1–R12 en web, Android e iOS.                                                                                   | Evidencia por versión candidata.                             |
| Responsive               | Anchos web y tamaños objetivo de Android/iOS; orientación y áreas seguras.                                      | Sin overflow, recorte o navegación inaccesible.              |
| Notificaciones           | Permisos concedidos/denegados, app abierta/cerrada, duplicados, programación, zona horaria y apertura profunda. | Entrega y persistencia verificadas sin avisos incorrectos.   |
| Recuperación             | Restauración de respaldo.                                                                                       | Datos críticos reconciliados.                                |
| Rendimiento              | Home, listas y formularios con volumen representativo.                                                          | Sin espera que impida tareas; objetivo medido y documentado. |

## 8.1 Datos de prueba mínimos

- Dos usuarios para comprobar aislamiento.

- Tres cuentas con diferentes saldos.

- Ingresos, gastos y transferencias de varios meses.

- Presupuesto global y por categoría.

- Deuda propia y préstamo por cobrar con pagos parciales.

- Meta activa, completada y con aporte revertido.

- Casos límite: cero, decimales, saldo insuficiente, vencidos y registros eliminados.

# 9. Rendimiento y operación

> ☐ El despliegue debe ejecutar migraciones controladamente y exponer un endpoint de salud.
>
> ☐ Frontend y backend deben tener variables de entorno separadas por ambiente.
>
> ☐ Los logs deben permitir investigar fallos sin incluir información sensible.
>
> ☐ Debe existir una forma clara de volver a una versión estable del frontend y backend.
>
> ☐ La base de datos debe monitorearse por disponibilidad, almacenamiento y errores.
>
> ☐ Las versiones desplegadas deben poder relacionarse con un commit o release.

# 10. Clasificación de defectos y bloqueadores

| **Nivel**   | **Definición**                                                                        | **Ejemplos**                                                                | **Regla de salida**                      |
|-------------|---------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|------------------------------------------|
| Crítico     | Pérdida, corrupción, exposición de datos o imposibilidad general de usar el producto. | Saldo incorrecto; acceso a datos ajenos; restauración imposible.            | Cero abiertos.                           |
| Importante  | Impide o confunde seriamente un recorrido esencial sin alternativa razonable.         | Pago no refresca Home; recuperación falla; formulario inaccesible en móvil. | Cero abiertos en R1–R12.                 |
| Conveniente | Molestia o inconsistencia con alternativa clara.                                      | Texto mejorable; un toque adicional; alineación menor.                      | Puede quedar registrada con responsable. |
| Futuro      | Nueva capacidad o expansión de alcance.                                               | Sincronización bancaria; amortizaciones; funciones sociales.                | No entra durante cierre V1.              |

# 11. Puerta objetiva de salida

La V1 candidata interna se considera completa cuando el alcance funcional y técnico obligatorio supera las pruebas internas. Luego se ejecuta la beta cerrada; la V1 se declara liberada únicamente cuando todos los criterios obligatorios están marcados, la retroalimentación fue clasificada y no quedan bloqueadores críticos o importantes.

> ☐ El alcance y las exclusiones de este contrato fueron aprobados por Felipe.
>
> ☐ Los recorridos R1–R12 funcionan de principio a fin.
>
> ☐ No existen defectos críticos ni importantes abiertos en recorridos esenciales.
>
> ☐ Saldos, movimientos, presupuestos, deudas, metas, Home y reportes se reconcilian.
>
> ☐ Las pruebas de aislamiento por usuario pasan.
>
> ☐ Secretos y CORS de producción fueron revisados.
>
> ☐ Existe respaldo automatizado o gestionado y una restauración de prueba exitosa.
>
> ☐ Web responsive, Android e iOS superan la revisión visual y funcional en los dispositivos objetivo definidos.
>
> ☐ El Home cumple su función de orientación: presenta información priorizada y accionable, usa cifras reales y no conserva mocks ni contenido simulado sin función explícita.
>
> ☐ Los estados vacío, carga, éxito y error están resueltos en pantallas esenciales.
>
> ☐ La batería mínima automatizada pasa en una ejecución limpia.
>
> ☐ El despliegue candidato está vinculado a una versión identificable.
>
> ☐ Entre cinco y diez probadores completan las tareas esenciales sin ayuda directa durante la beta cerrada.
>
> ☐ La retroalimentación de beta fue clasificada y los bloqueadores fueron cerrados.
>
> ☐ El backlog posterior contiene todo lo aplazado, sin tareas invisibles.

| **DEFINICIÓN DE TERMINADO** CronoFinanzas V1 está terminada cuando una persona real puede controlar su situación financiera básica con datos confiables, privacidad, recuperación y una experiencia coherente, mientras todo lo no esencial queda explícitamente fuera del lanzamiento. |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

# 12. Plan de beta cerrada

## 12.1 Participantes y duración propuesta

Cinco a diez personas de confianza durante catorce días, convocadas únicamente después de completar la V1 candidata interna. Deben aceptar que es una beta, usar datos ficticios o de bajo riesgo durante la primera ronda y reportar problemas mediante un canal definido.

## 12.2 Tareas del probador

- Crear acceso y recuperar la contraseña.

- Configurar al menos dos cuentas.

- Registrar movimientos durante tres días.

- Crear un presupuesto y explicar su progreso.

- Registrar una deuda o préstamo y un pago/cobro.

- Crear una meta y aportar.

- Encontrar cuánto gastó en una categoría.

- Recibir, abrir y gestionar una notificación relevante.

- Registrar un movimiento con la burbuja flotante en Android o iOS.

- Explicar qué entiende al observar el Home.

## 12.3 Evidencia a recopilar

- Tarea completada o abandonada.

- Tiempo aproximado y punto de confusión.

- Captura o grabación solo con consentimiento y datos no sensibles.

- Resultado esperado frente al observado.

- Severidad según la clasificación del contrato.

# 13. Orden de trabajo para cerrar la V1

| **Bloque**               | **Objetivo**                                                                           | **Salida verificable**                                                  |
|--------------------------|----------------------------------------------------------------------------------------|-------------------------------------------------------------------------|
| 0\. Congelar             | Aprobar contrato, detener funciones nuevas y crear backlog único.                      | Alcance firmado y tablero clasificado.                                  |
| 1\. Confiabilidad        | Integridad financiera, ownership, secretos, respaldo y pruebas.                        | Bloqueadores técnicos cerrados.                                         |
| 2\. Recorridos           | Corregir R1–R12 en web, Android e iOS.                                                 | Checklist funcional completo.                                           |
| 3\. Coherencia visual    | Aplicar Design System necesario a flujos esenciales.                                   | Revisión responsive aprobada.                                           |
| 4\. V1 candidata interna | Desplegar versiones identificables en web, Android e iOS y ejecutar pruebas completas. | Candidata interna completa, sin críticos/importantes y lista para beta. |
| 5\. Beta cerrada         | Validar la V1 candidata con 5–10 personas y corregir bloqueadores.                     | Informe de beta, recorridos validados y decisión de liberación.         |
| 6\. Liberación V1        | Etiquetar V1, documentar operación y mover pendientes.                                 | V1 liberada y backlog V1.1.                                             |

# 14. Decisiones de alcance confirmadas y controles previos a beta

Las decisiones de alcance D1–D6 ya fueron confirmadas por Felipe y deben guiar la implementación. Los controles D7–D10 se revisarán cuando la V1 candidata interna esté completa, antes de convocar la beta cerrada; no reabren el alcance salvo que aparezca un riesgo crítico.

| **ID** | **Decisión**           | **Recomendación actual**                                                | **Alternativa e impacto**                                                                              |
|--------|------------------------|-------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| D1     | Plataformas            | Confirmado: web responsive, Android e iOS.                              | Las tres plataformas bloquean la V1 y requieren evidencia de prueba.                                   |
| D2     | Notificaciones         | Confirmado: internas y persistentes, con todo el flujo relacionado.     | Incluye permisos, programación, entrega, apertura, preferencias y casos de app abierta/cerrada.        |
| D3     | Captura rápida         | Confirmado: burbuja o botón flotante dentro de la app móvil.            | Debe funcionar en Android e iOS y convivir con el formulario completo.                                 |
| D4     | Home                   | Confirmado: será mejorado para cumplir su función de orientación.       | Se priorizará claridad, información real, acciones y próximos compromisos; no solo un cambio estético. |
| D5     | Beta                   | Confirmado: 5–10 personas después de completar la V1 candidata interna. | La beta valida comprensión y estabilidad; no decide el alcance base.                                   |
| D6     | Nivel visual           | Confirmado: coherencia profesional en flujos esenciales.                | El Design System se aplicará por bloques sin exigir cerrar los 11 documentos antes de avanzar.         |
| D7     | Dispositivos objetivo  | Confirmar antes de beta.                                                | Definir versiones mínimas de iOS/Android, tamaños y navegadores web que se probarán.                   |
| D8     | Canal y soporte beta   | Confirmar antes de beta.                                                | Elegir canal de reporte, responsable, tiempo de respuesta y protocolo ante incidentes.                 |
| D9     | Datos y consentimiento | Confirmar antes de beta.                                                | Definir datos ficticios/reales permitidos, aviso de beta y consentimiento para capturas o grabaciones. |
| D10    | Distribución beta      | Confirmar antes de beta.                                                | Definir TestFlight para iOS y el mecanismo controlado para Android/web, con acceso revocable.          |

## 14.1 Control de preparación para beta

**Aprobación de alcance registrada:** Felipe aprobó el contrato V1 v0.2 sin cambios de alcance el 12 de agosto de 2026.

- [x] D1–D6 y la frontera R1–R12 quedan aprobados como obligación de la V1.
- [ ] La V1 candidata interna cumple D1–D6 y los recorridos R1–R12.
- [ ] Se definieron D7–D10 y están listos los medios de distribución y soporte.
- [ ] Felipe autoriza iniciar la beta cerrada con 5–10 personas.

# 15. Backlog posterior a V1

| **Horizonte** | **Candidatos**                                                                                    | **Condición para priorizar**                                |
|---------------|---------------------------------------------------------------------------------------------------|-------------------------------------------------------------|
| V1.1          | Mejoras UX de beta, notificaciones seleccionadas, educación ampliada, pulido del Design System.   | Evidencia de uso o confusión; bajo riesgo arquitectónico.   |
| V1.x          | Recordatorios avanzados, comprobantes, exportación, automatizaciones simples.                     | Demanda repetida y reglas de datos claras.                  |
| V2            | Sincronización bancaria, finanzas compartidas, cuotas/amortización, productos financieros nuevos. | Validación de mercado, seguridad y arquitectura específica. |
| Exploración   | Gamificación, IA financiera, comunidad, integraciones externas.                                   | Hipótesis y pruebas de valor antes de construir.            |

# 16. Gobierno del alcance

## 16.1 Solicitud de cambio

Toda propuesta que intente entrar en V1 debe responder por escrito:

- ¿Qué recorrido esencial está bloqueado sin este cambio?

- ¿Qué riesgo de datos, seguridad o confianza corrige?

- ¿Qué repositorio y módulos afecta?

- ¿Qué puede romperse?

- ¿Cómo se probará?

- ¿Qué trabajo aprobado se desplaza para incluirlo?

## 16.2 Regla de decisión

Si la respuesta no demuestra un bloqueo de V1, el cambio pasa al backlog. Si sí lo demuestra, Felipe aprueba su entrada y se actualiza este contrato con número de versión y motivo.

# 17. Registro inicial de riesgos

| **Riesgo**                              | **Impacto**                                                | **Tratamiento V1**                                                      | **Propietario**               |
|-----------------------------------------|------------------------------------------------------------|-------------------------------------------------------------------------|-------------------------------|
| Inconsistencia entre módulos            | Pérdida de confianza y decisiones erróneas.                | Pruebas de reconciliación y operaciones vinculadas.                     | Producto + desarrollo         |
| Acceso cruzado                          | Exposición de información financiera.                      | Ownership sistemático y pruebas con dos usuarios.                       | Backend                       |
| Sin restauración probada                | Pérdida irreversible de datos.                             | Política, copia y simulacro antes de beta real.                         | Operación                     |
| Design System incompleto                | Inconsistencia y retrabajo.                                | Aplicación incremental en flujos esenciales.                            | Producto + frontend           |
| Alcance creciente                       | V1 nunca termina.                                          | Congelamiento y control de cambios.                                     | Felipe                        |
| Notificaciones incorrectas o duplicadas | Pérdida de confianza, fatiga o acciones fuera de contexto. | Pruebas de permisos, entrega, zona horaria, deduplicación y navegación. | Producto + frontend + backend |
| Pruebas insuficientes                   | Regresiones al corregir módulos.                           | Batería mínima y release candidate.                                     | Desarrollo                    |
| Diferencias entre plataformas           | Una tarea funciona en web o Android pero falla en iOS.     | Matriz común de pruebas y dispositivos objetivo antes de beta.          | Producto + frontend           |

# 18. Evidencia técnica utilizada

Esta primera versión se apoya en el estado maestro del proyecto y en la revisión de la rama main de ambos repositorios al 12 de agosto de 2026.

- Frontend Flutter con estructura por funcionalidades, Riverpod, endpoints /api/v1 y distribución responsive en móvil, tableta y escritorio.

- Navegación visible para Inicio, Cuentas, Movimientos, Categorías, Deudas, Metas, Presupuestos, Reportes, Educación, Alertas y Perfil.

- Endpoints frontend para autenticación, usuarios, cuentas, transacciones, captura rápida, categorías, presupuestos, reportes, notificaciones, deudas/préstamos y metas.

- Backend FastAPI con rutas equivalentes, autenticación JWT, CORS configurable, health check y migraciones Alembic.

- Operaciones de deuda/préstamo y metas protegidas por usuario, con pagos/aportes y eliminaciones relacionadas.

- Pruebas iniciales en frontend y backend, pero cobertura financiera todavía insuficiente para la puerta V1.

- Ausencia visible de una política y simulacro de restauración documentados en los repositorios revisados.

## 18.1 Fuentes de repositorio

**CronoFinanzas Frontend:** https://github.com/FelipeOA16/CronoFinanzas_Frontend

**CronoFinanzas Backend:** https://github.com/FelipeOA16/CronoFinanzas_backend

# 19. Próxima revisión y ejecución sugerida

Primero, este contrato v0.2 se usa para clasificar deuda técnica, observaciones de interfaz y documentos visuales. Segundo, se implementan y prueban por bloques los recorridos R1–R12 en web, Android e iOS. Tercero, cuando la V1 candidata interna esté completa, Felipe confirma los controles D7–D10 y autoriza la beta cerrada. Finalmente, se corrigen los bloqueadores de beta y se libera la V1.

| **SIGUIENTE HITO** Aprobar la frontera de V1. El éxito inmediato no es agregar otra función: es lograr que cada tarea existente tenga un lugar claro —bloquea V1, mejora V1.1 o visión futura— y que el proyecto vuelva a avanzar con una dirección única. |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
