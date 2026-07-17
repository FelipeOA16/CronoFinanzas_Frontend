# Backend Configuration for CronoFinanzas Frontend

## Required Backend Setup

The frontend expects a FastAPI backend with JWT Bearer authentication.

### Base Configuration

- **Base URL (Development)**: `http://localhost:8000`
- **API Prefix**: `/api/v1`
- **Authentication**: JWT Bearer tokens

### To Change Base URL

Edit [`lib/core/config/env.dart`](lib/core/config/env.dart):

```dart
class Env {
  static const String devBaseUrl = 'http://your-backend-url:8000';
  static const String prodBaseUrl = 'https://api.production.com';

  static String get baseUrl {
    // Change to prodBaseUrl for production
    return devBaseUrl;
  }
}
```

### Expected Backend Endpoints

All endpoints are defined in [`lib/core/config/endpoints.dart`](lib/core/config/endpoints.dart):

- `POST /api/v1/auth/login`
- `GET /api/v1/auth/me`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/logout`

### Request/Response Formats

#### Login Request
```json
POST /api/v1/auth/login
Content-Type: application/json

{
  "identifier": "user@example.com or username",
  "password": "userpassword"
}
```

#### Login Response
```json
200 OK
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

#### Get User Profile Request
```http
GET /api/v1/auth/me
Authorization: Bearer {access_token}
```

#### Get User Profile Response
```json
200 OK
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "email": "user@example.com",
  "username": "username",
  "role": "ADMIN",
  "is_active": true,
  "created_at": "2026-01-16T12:34:56.789Z"
}
```

#### Refresh Token Request
```json
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### Refresh Token Response
```json
200 OK
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

#### Logout Request
```json
POST /api/v1/auth/logout
Content-Type: application/json

{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### Logout Response
```
204 No Content
```

### Error Responses

The app expects FastAPI error format:

#### 401 Unauthorized
```json
{
  "detail": "Invalid credentials"
}
```

or

```json
{
  "detail": "Could not validate credentials"
}
```

#### 422 Validation Error
```json
{
  "detail": [
    {
      "loc": ["body", "password"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

#### 400 Bad Request
```json
{
  "detail": "Inactive user"
}
```

## Token Refresh Flow

The app automatically refreshes tokens when:

1. A request to a protected endpoint returns 401
2. The interceptor catches the error
3. Attempts to refresh using the stored refresh token
4. If successful:
   - Saves new tokens
   - Retries the original request
5. If refresh fails:
   - Clears all tokens
   - Redirects to login

## Security Notes

- Tokens are stored using `flutter_secure_storage`
- All HTTP requests use HTTPS in production
- Password validation includes UTF-8 byte length check (max 72 bytes for bcrypt)
- Automatic token rotation on refresh

## Testing the Integration

1. Start your FastAPI backend
2. Ensure it's running on `http://localhost:8000`
3. Run the Flutter app: `flutter run`
4. Try logging in with valid credentials
5. Check that the home screen loads with user data
6. Test logout functionality
