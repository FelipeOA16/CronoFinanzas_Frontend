# CronoFinanzas Frontend

Flutter multiplatform app with Clean Architecture (feature-first) + Riverpod + Dio.

## Architecture

### Clean Architecture Layers

- **Domain**: Business logic (entities, repositories interfaces, use cases)
- **Data**: Implementation details (models, data sources, repository implementations)
- **Presentation**: UI layer (screens, widgets, state management)

### Project Structure

```
lib/
├── core/                           # Core utilities and shared code
│   ├── config/
│   │   ├── env.dart               # Environment configuration
│   │   └── endpoints.dart         # API endpoints
│   ├── errors/
│   │   ├── exceptions.dart        # Exception classes
│   │   ├── failures.dart          # Failure classes
│   │   └── result.dart            # Result type (Either-like)
│   ├── network/
│   │   ├── dio_client.dart        # Dio configuration
│   │   ├── api_client.dart        # API client wrapper
│   │   └── interceptors.dart      # Auth interceptor with token refresh
│   ├── storage/
│   │   ├── token_storage.dart     # Token storage interface
│   │   └── secure_token_storage.dart  # Secure storage implementation
│   └── utils/
│       └── validators.dart        # Form validators
├── src/
│   ├── app/                       # App-level configuration
│   │   ├── theme/
│   │   │   └── app_theme.dart     # App theme
│   │   ├── router/
│   │   │   └── app_router.dart    # Router configuration
│   │   └── di/
│   │       └── providers.dart     # Global Riverpod providers
│   ├── auth/                      # Authentication feature
│   │   ├── domain/
│   │   │   ├── entities/          # Auth entities
│   │   │   ├── repos/             # Repository interfaces
│   │   │   └── usecases/          # Use cases (login, logout, etc.)
│   │   ├── data/
│   │   │   ├── models/            # Data models
│   │   │   ├── datasources/       # Remote data sources
│   │   │   └── repos/             # Repository implementations
│   │   └── presentation/
│   │       ├── app/riverpod/      # Auth state management
│   │       ├── views/             # Screens
│   │       └── widgets/           # Auth widgets
│   └── home/                      # Home feature
│       └── presentation/
│           └── views/             # Home screen
└── main.dart                      # App entry point
```

## Features

### Authentication Flow

1. **Login**:
   - User enters credentials (identifier + password)
   - Validates input (required fields, password length, UTF-8 byte limit)
   - POST `/api/v1/auth/login`
   - Saves tokens securely
   - GET `/api/v1/auth/me` to fetch user data
   - Navigates to home screen

2. **Session Management**:
   - On app start, checks for existing tokens
   - Attempts to load user profile
   - If tokens are invalid, returns to login

3. **Token Refresh**:
   - Automatic refresh on 401 responses
   - Interceptor handles token rotation
   - Retries original request with new token

4. **Logout**:
   - POST `/api/v1/auth/logout` with refresh token
   - Clears local tokens
   - Navigates to login screen

## API Contract

**Base URL**: `http://localhost:8000` (dev)
**Prefix**: `/api/v1`

### Endpoints

#### POST /api/v1/auth/login
```json
Request:
{
  "identifier": "string",
  "password": "string"
}

Response 200:
{
  "access_token": "string",
  "refresh_token": "string",
  "token_type": "bearer"
}
```

#### GET /api/v1/auth/me
```
Headers: Authorization: Bearer {access_token}

Response 200:
{
  "id": "uuid",
  "email": "user@example.com",
  "username": "user1",
  "role": "ADMIN" | "USER",
  "is_active": true,
  "created_at": "2026-01-16T12:34:56.789Z"
}
```

#### POST /api/v1/auth/refresh
```json
Request:
{
  "refresh_token": "string"
}

Response 200: (same as login)
```

#### POST /api/v1/auth/logout
```json
Request:
{
  "refresh_token": "string"
}

Response 204: (no body)
```

## Dependencies

- **flutter_riverpod**: State management
- **dio**: HTTP client
- **flutter_secure_storage**: Secure token storage

## State Management

### AuthState
- `AuthIdle`: Initial state, no user
- `AuthLoading`: Loading user data
- `AuthAuthenticated(user)`: User is logged in
- `AuthError(message)`: Error occurred

### AuthController
- `loginUser()`: Login with credentials
- `loadSession()`: Load user from stored tokens
- `logoutUser()`: Logout and clear tokens

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build for production
flutter build [platform]
```

## Development Notes

- No code generation (build_runner) - manual models
- Snake_case for file names
- One class per file
- Domain layer is pure Dart (no Flutter dependencies)
- Presentation doesn't import data layer directly
- Result<T> type for error handling (instead of exceptions in domain)
