# CronoFinanzas Frontend

Frontend Flutter de CronoFinanzas. Esta carpeta esta preparada para funcionar como repositorio independiente tomando `frontend/` como raiz del proyecto.

## Requisitos

- Flutter estable.
- Dart incluido con Flutter.
- Android Studio o SDK Android para builds Android.
- Backend FastAPI accesible.

## Instalacion

Desde `frontend/`:

```bash
flutter pub get
```

## Configuracion de API

La URL del backend se define con `API_BASE_URL`.

Ejecucion local:

```powershell
flutter run --dart-define=API_BASE_URL=http://localhost:8050
```

Ejemplo usando puerto backend directo:

```powershell
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

Build web:

```powershell
flutter build web --release --dart-define=API_BASE_URL=https://URL-PUBLICA-DEL-BACKEND
```

No pongas en Flutter secretos de backend como `DATABASE_URL`, `SECRET_KEY`, `RESEND_API_KEY`, claves service_role o contrasenas.

## Analisis y pruebas

```bash
flutter analyze
flutter test
```

## Build web

```bash
flutter build web --release --dart-define=API_BASE_URL=http://localhost:8050
```

## Build Android

```bash
flutter build apk --release --dart-define=API_BASE_URL=http://localhost:8050
```

Para un dispositivo fisico, usa una IP o dominio alcanzable desde el telefono.

## Docker / Nginx

Construir imagen web:

```bash
docker build --build-arg API_BASE_URL=http://localhost:8050 -t cronofinanzas-frontend .
```

El `Dockerfile` compila Flutter Web y sirve `build/web` con Nginx.

## Estructura

```text
lib/
  core/             Configuracion, network, design system
  src/app/          Router, shell, providers globales
  src/auth/         Autenticacion
  src/finances/     Features financieras
  src/home/         Home
  src/education/    Educacion financiera
assets/             Marca e ilustraciones
android/ ios/ web/  Plataformas Flutter
test/               Tests
```

## Comunicacion con FastAPI

Flutter usa Dio y endpoints bajo `/api/v1`. La base URL debe venir de `API_BASE_URL` o de los defaults locales de `lib/core/config/env.dart`.

Ver tambien `docs/INTEGRATION.md`.
