# 🧪 Testing Guide - CronoFinanzas Frontend

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device_id>

# Run with hot reload enabled (default)
flutter run --hot
```

## Testing Login Flow

### With Real Backend

1. **Start your FastAPI backend**:
   ```bash
   cd /path/to/backend
   uvicorn main:app --reload
   ```

2. **Update base URL if needed** in [`lib/core/config/env.dart`](lib/core/config/env.dart):
   ```dart
   static const String devBaseUrl = 'http://localhost:8000';
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

4. **Test credentials**:
   - Use credentials from your backend database
   - Example: `admin` / `admin123`

### Without Backend (Mock Testing)

If you want to test the UI without a backend:

1. **Option 1**: Use a mock API service (like Postman Mock Server)
2. **Option 2**: Modify the data source to return fake data temporarily

## Testing Token Refresh

1. Login to the app
2. Wait for the access token to expire (check backend JWT expiration time)
3. Navigate or perform an action that requires authentication
4. The app should automatically refresh the token and retry the request

To force a token refresh:
- Manually edit the access token in secure storage to an invalid value
- Make a request to `/me` endpoint
- Check logs to see refresh flow

## Testing Logout

1. Login to the app
2. Navigate to Home screen
3. Click the logout button (top-right)
4. Verify:
   - Tokens are cleared from secure storage
   - App navigates back to login screen
   - Backend receives logout request

## Debugging

### Enable Dio Logging

Add to [`lib/core/network/dio_client.dart`](lib/core/network/dio_client.dart):

```dart
import 'package:dio/dio.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  // ...
}
```

### Check Stored Tokens

Add a temporary debug function:

```dart
// In lib/core/storage/secure_token_storage.dart

Future<void> debugPrintTokens() async {
  final accessToken = await getAccessToken();
  final refreshToken = await getRefreshToken();
  print('Access Token: $accessToken');
  print('Refresh Token: $refreshToken');
}
```

Call it from your controller or widget to inspect tokens.

### Monitor Auth State

In your UI, add a listener:

```dart
ref.listen<AuthState>(authControllerProvider, (previous, next) {
  print('Auth State Changed: $previous -> $next');

  if (next is AuthLoading) {
    print('Loading...');
  } else if (next is AuthAuthenticated) {
    print('Authenticated: ${next.user.email}');
  } else if (next is AuthError) {
    print('Error: ${next.message}');
  } else {
    print('Idle');
  }
});
```

## Common Issues

### 1. Connection Refused

**Problem**: `DioException: Connection refused`

**Solution**:
- Check backend is running: `curl http://localhost:8000/api/v1/auth/login`
- For Android emulator, use `http://10.0.2.2:8000` instead of `localhost`
- For iOS simulator, `localhost` should work

Update `env.dart`:
```dart
static const String devBaseUrl = 'http://10.0.2.2:8000'; // Android emulator
```

### 2. 401 Unauthorized Loop

**Problem**: App keeps refreshing tokens infinitely

**Solution**:
- Check refresh token endpoint is working
- Verify refresh token is not expired
- Clear app storage and login again

### 3. Secure Storage Issues

**Problem**: `flutter_secure_storage` not working on emulator

**Solution**:
- Enable screen lock on Android emulator
- For iOS simulator, ensure iCloud keychain is enabled
- Alternatively, use a real device

### 4. CORS Errors (Web)

**Problem**: CORS policy blocking requests

**Solution**:
- Add CORS middleware to FastAPI backend:
  ```python
  from fastapi.middleware.cors import CORSMiddleware

  app.add_middleware(
      CORSMiddleware,
      allow_origins=["http://localhost:*"],
      allow_credentials=True,
      allow_methods=["*"],
      allow_headers=["*"],
  )
  ```

## Test Cases

### ✅ Happy Path

1. **First Launch**
   - App shows login screen
   - No tokens in storage

2. **Successful Login**
   - Enter valid credentials
   - See loading indicator
   - Navigate to home screen
   - Display user info

3. **App Restart (Session Persistence)**
   - Close app
   - Reopen app
   - See loading indicator briefly
   - Automatically navigate to home screen

4. **Logout**
   - Click logout button
   - Return to login screen
   - Tokens cleared from storage

### ❌ Error Cases

1. **Invalid Credentials**
   - Enter wrong username/password
   - See error message in SnackBar
   - Stay on login screen

2. **Network Error**
   - Disconnect internet
   - Try to login
   - See network error message

3. **Server Error**
   - Backend returns 500
   - See server error message

4. **Validation Errors**
   - Empty identifier → "Identifier is required"
   - Empty password → "Password is required"
   - Password < 6 chars → "Password must be at least 6 characters"
   - Password > 72 bytes → "Password exceeds maximum length (72 bytes)"

5. **Expired Tokens**
   - Access token expires
   - Make authenticated request
   - Token automatically refreshes
   - Request succeeds

6. **Invalid Refresh Token**
   - Refresh token expires
   - Make authenticated request
   - Refresh fails
   - User redirected to login

## Performance Testing

### Measure Load Time

```dart
// In main.dart
void main() {
  final stopwatch = Stopwatch()..start();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    print('App loaded in ${stopwatch.elapsedMilliseconds}ms');
  });
}
```

### Monitor Network Requests

Use Flutter DevTools:
```bash
flutter run --observatory-port=8888
```

Open in browser: http://localhost:8888

## Automated Testing

### Unit Tests (Future)

```dart
// test/domain/usecases/login_test.dart
void main() {
  test('login returns AuthTokens on success', () async {
    // Arrange
    final mockRepo = MockAuthRepository();
    final useCase = Login(mockRepo);

    // Act
    final result = await useCase(
      identifier: 'test',
      password: 'password',
    );

    // Assert
    expect(result.isOk, true);
    expect(result.data, isA<AuthTokens>());
  });
}
```

### Widget Tests (Future)

```dart
// test/presentation/widgets/login_form_test.dart
void main() {
  testWidgets('login form validates input', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      ),
    );

    // Tap login without entering credentials
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    // Expect validation errors
    expect(find.text('Identifier is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}
```

## Build for Release

### Android

```bash
# Build release APK
flutter build apk --release

# Build release AAB (for Play Store)
flutter build appbundle --release

# Install release APK on device
flutter install --release
```

### iOS

```bash
# Build release IPA
flutter build ios --release

# Or build for simulator
flutter build ios --debug --simulator
```

### Web

```bash
flutter build web --release
```

---

## 📊 Metrics to Monitor

- Login success rate
- Average login time
- Token refresh success rate
- App crash rate on login
- Network error frequency
- API response times
