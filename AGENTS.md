# AGENTS.md - CronoFinanzas Frontend

Trabaja siempre tomando `frontend/` como raiz.

## Comandos

```bash
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://localhost:8050
flutter build web --release --dart-define=API_BASE_URL=http://localhost:8050
```

## Reglas

- Usar `API_BASE_URL` para apuntar al backend.
- No incluir secretos administrativos en Flutter.
- No agregar `DATABASE_URL`, `SECRET_KEY`, `RESEND_API_KEY`, service_role keys ni contrasenas.
- Respetar el Design System Chakana y componentes reutilizables.
- Documentar cambios en consumo de endpoints.
- No eliminar plataformas Flutter existentes.
- No agregar `build/`, `.dart_tool/`, keystores ni artefactos locales al repositorio.

## Convenciones

- Configuracion en `lib/core/config/`.
- Network en `lib/core/network/`.
- Features en `lib/src/`.
- Design System en `lib/core/design_system/`.
- Tests en `test/`.
