# Debug Rápido - Problema de Login

## Estado Actual
- App carga en Edge
- Login muestra loading pero vuelve a pantalla de login
- Backend no recibe solicitudes

## Pasos para Diagnosticar

### 1. Verificar Backend
```bash
# ¿Está corriendo tu backend?
# Debe estar en http://localhost:8000
curl http://localhost:8000/api/v1/auth/login
```

### 2. Ver Logs en el Navegador
1. Abre Edge/Chrome
2. Presiona F12 (Herramientas de desarrollador)
3. Ve a la pestaña "Console"
4. Intenta hacer login
5. Busca mensajes que empiecen con:
   - `[AuthController]`
   - `[AuthDataSource]`
   - `[ApiClient]`

### 3. Revisar Errores de Red
1. En DevTools, ve a "Network" (Red)
2. Intenta hacer login
3. Busca la solicitud a `/api/v1/auth/login`
4. Si aparece en rojo, haz clic para ver el error

## Posibles Problemas y Soluciones

### Problema 1: CORS
**Síntoma**: Error en consola: "blocked by CORS policy"

**Solución**: Agregar CORS middleware en tu backend FastAPI:
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8080", "http://localhost:*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Problema 2: Backend no está corriendo
**Síntoma**: Error "Connection refused" o "ERR_CONNECTION_REFUSED"

**Solución**:
1. Inicia tu backend
2. Verifica que esté en el puerto 8000

### Problema 3: URL incorrecta
**Síntoma**: Error 404 Not Found

**Solución**: Verificar en `lib/core/config/env.dart` que la URL sea correcta

### Problema 4: flutter_secure_storage en Web
**Síntoma**: Error al guardar tokens

**Solución temporal**: En web, secure_storage usa localStorage. Puede haber problemas.
Prueba limpiar caché: Ctrl+Shift+Delete -> Borrar datos de navegación

## Solución Temporal: Logging Mejorado

Ya agregué logs de debug. Los mensajes que debes ver:

```
[AuthController] Starting login for: tu_usuario
[AuthDataSource] Attempting login to: /api/v1/auth/login
[AuthDataSource] Identifier: tu_usuario
[ApiClient] Making request...
[ApiClient] Response status: 200   <- Si llega aquí, el backend respondió
[AuthController] Got tokens, saving...
[AuthController] Fetching user profile...
[AuthController] Login successful! User: tu_email
```

Si no ves estos mensajes, anota en qué punto se detiene.

## Comando Rápido para Ver Logs

En la terminal donde corriste `flutter run`:
- Los logs aparecerán automáticamente
- También en la consola del navegador (F12)

## Si Necesitas Reiniciar

```bash
# Detener la app
# Presiona 'q' en la terminal donde corre flutter run

# O reiniciar con hot reload
# Presiona 'r' en la terminal
```
