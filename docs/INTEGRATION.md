# Integracion Frontend - Backend

Contrato general desde el punto de vista Flutter.

## API_BASE_URL

Configura la URL del backend con `--dart-define`:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8050
```

Build web:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://URL-PUBLICA-DEL-BACKEND
```

## Prefijo API

Los endpoints viven bajo:

```text
/api/v1
```

## Autenticacion

- Flutter guarda access token y refresh token con `flutter_secure_storage`.
- Dio agrega `Authorization: Bearer <access_token>`.
- Si el backend responde 401, el interceptor intenta refresh.
- Si el refresh falla, la app limpia sesion y vuelve a login.

## CORS

El backend debe permitir el origen desde el que se sirve Flutter Web. En local Docker:

```text
http://localhost:8051
```

## Variables que NO pertenecen al frontend

- `DATABASE_URL`
- `DB_PASSWORD`
- `SECRET_KEY`
- `RESEND_API_KEY`
- Supabase service_role o claves administrativas
- Tokens administrativos

## Captura rapida Android

El overlay Android usa la misma `API_BASE_URL` compilada en Flutter y recibe un snapshot de sesion desde la app. No almacena refresh token.

Si cambia el contrato de Captura Rapida, actualizar este documento y la documentacion backend.
