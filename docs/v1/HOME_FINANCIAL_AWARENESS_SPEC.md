# Especificación V1 — Home de conciencia financiera

**Estado:** Aprobado para ejecución  
**Fuente superior:** [Contrato de alcance y salida V1 v0.2](./CONTRACT_SCOPE_RELEASE_V1_v0.2.md)  
**Recorrido principal:** R9 — Comprender el Home  
**Plataformas:** web responsive, Android e iOS

## 1. Propósito

El Home no es un tablero que resume obligatoriamente todos los módulos. Su función es ayudar al usuario a comprender su situación inmediata y reconocer la siguiente información o acción financiera que merece atención.

Debe responder cuatro preguntas como filtro editorial y funcional, sin convertirlas en cuatro tarjetas fijas:

1. **Control:** ¿Cuánto dinero tengo disponible ahora?
2. **Margen:** ¿Cuánto margen me queda este mes?
3. **Cumplimiento de decisiones:** ¿Estoy cumpliendo lo que decidí hacer con mi dinero?
4. **Atención:** ¿Qué necesita mi atención ahora?

## 2. Definiciones financieras

- **Saldo actual:** suma de los saldos de todas las cuentas activas.
- **Posición neta:** saldo actual + dinero por cobrar − dinero por pagar.
- **Regla de jerarquía:** Saldo actual es la cifra principal. Posición neta es secundaria y aparece solo cuando aporta información distinta; se oculta cuando es redundante.
- **Concepto retirado:** no mostrar “Patrimonio actual” como indicador del Home.

Toda cifra debe tener fuente real, trazable y explicable. No se permiten mocks o contenido simulado sin una función explícita y visible.

## 3. Arquitectura móvil aprobada

1. **Header**
   - Identidad y contexto mínimo.
   - Accesos esenciales sin competir con el contenido financiero.

2. **Posición actual**
   - Saldo actual como información principal.
   - Posición neta opcional según la regla anterior.
   - Acción para ocultar/mostrar importes cuando corresponda.

3. **Este mes**
   - Presentación compacta del margen.
   - Mostrar restante y porcentaje del presupuesto usando la lógica financiera existente.
   - No duplicar el módulo completo de presupuestos.

4. **Ahora importa**
   - Máximo una situación prioritaria.
   - Orden de prioridad: vencido → hoy → próximo → presupuesto crítico → decisión financiera relevante → meta → captura pendiente.
   - Desaparece cuando no existe una situación relevante.
   - Debe navegar al contexto correcto.

5. **Último movimiento**
   - Máximo un movimiento real.
   - Permite consulta inmediata; no sustituye el historial.

6. **Navegación inferior**
   - Máximo cinco destinos: Inicio, Cuentas, Nueva transacción, Presupuestos y Más.
   - “Más” contiene Deudas, Metas, Reportes, Educación, Categorías, Alertas, Perfil y cerrar sesión.
   - Evitar un FAB duplicado si “Nueva transacción” ya ocupa un destino principal.

## 4. Web y tableta

Web conserva el mismo significado y reglas, pero puede usar mayor densidad, comparación y distribución horizontal.

- Escritorio `>=1200 px`: sidebar expandido.
- Tableta `840–1199 px`: sidebar compacto o NavigationRail.
- Móvil `<840 px`: navegación inferior descrita arriba.
- La mayor densidad web no autoriza convertir el Home nuevamente en un resumen de todos los módulos.
- Posición actual, Este mes, Ahora importa y Último movimiento mantienen su jerarquía semántica.

## 5. Contenido que se retira del Home como bloque fijo

- Tarjetas independientes de ingresos, gastos y ahorro.
- Resúmenes permanentes de metas.
- Resúmenes permanentes de deudas y préstamos.
- Lista extensa de compromisos.
- Bloque permanente de capturas rápidas.
- Lista de tres o más movimientos.
- Yachay/Educación como bloque permanente.
- Consejos simulados o no trazables.
- “Patrimonio actual”.

Los módulos siguen accesibles desde su navegación. Retirarlos del Home no elimina sus funciones.

## 6. Estados obligatorios

Cada sección debe resolver, cuando corresponda:

- carga;
- vacío;
- éxito;
- error;
- datos ocultos;
- navegación al contexto;
- actualización posterior a una operación;
- ausencia legítima de una alerta o prioridad.

## 7. Criterios de aceptación de R9

R9 se aprueba cuando:

- el usuario explica sin ayuda qué representa cada cifra;
- Saldo actual coincide con la suma de cuentas activas;
- Posición neta coincide con su fórmula y respeta su aparición condicional;
- el margen mensual coincide con presupuestos y movimientos;
- “Ahora importa” muestra como máximo una prioridad real;
- el último movimiento es trazable al historial;
- ingreso, gasto, transferencia, pago, cobro, aporte o reversión refresca el Home sin recarga manual;
- no quedan mocks ni el indicador “Patrimonio actual”;
- móvil permite consulta rápida y uso con una mano;
- web permite mayor análisis sin cambiar el significado;
- no existen overflow, recortes o controles inaccesibles en los tamaños objetivo.

## 8. Fuera de alcance de este bloque

- Rediseñar reglas financieras de módulos.
- Crear nuevos productos financieros.
- Añadir gamificación, IA o recomendaciones complejas.
- Completar los once documentos del Design System.
- Convertir las cuatro preguntas en cuatro tarjetas fijas.
